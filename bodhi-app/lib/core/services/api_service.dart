import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  late final Dio _dio;
  String? _token;

  ApiService({String baseUrl = 'http://localhost:8000'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));
  }

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  // ─── Auth ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final res = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return res.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
    _token = res.data['access_token'];
    return res.data;
  }

  Future<Map<String, dynamic>> register({
    required String phone,
    required String name,
    required String role,
    String? address,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'phone': phone,
      'name': name,
      'role': role,
      'address': address,
    });
    _token = res.data['access_token'];
    return res.data;
  }

  Future<Map<String, dynamic>> verifyPin(String phone, String pin) async {
    final res = await _dio.post('/auth/verify-pin', data: {'phone': phone, 'pin': pin});
    _token = res.data['access_token'];
    return res.data;
  }

  // ─── Services ─────────────────────────────────────────────────

  Future<List<dynamic>> getServiceCategories() async {
    final res = await _dio.get('/services/categories');
    return res.data;
  }

  Future<List<dynamic>> getServices(String serviceType) async {
    final res = await _dio.get('/services/categories/$serviceType/services');
    return res.data;
  }

  // ─── Bookings ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    final res = await _dio.post('/bookings/', data: data);
    return res.data;
  }

  Future<List<dynamic>> getBookings({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    final res = await _dio.get('/bookings/', queryParameters: params);
    return res.data;
  }

  Future<Map<String, dynamic>> getBooking(int id) async {
    final res = await _dio.get('/bookings/$id');
    return res.data;
  }

  Future<void> updateBookingStatus(int id, String status, {String? note}) async {
    await _dio.patch('/bookings/$id/status', data: {'status': status, 'note': note});
  }

  Future<void> verifyBookingOtp(int id, String otp) async {
    await _dio.post('/bookings/$id/verify-otp', queryParameters: {'otp': otp});
  }

  Future<void> rateBooking(int id, int rating, {String? review}) async {
    await _dio.post('/bookings/$id/rate', data: {'rating': rating, 'review': review});
  }

  // ─── Hospitals ────────────────────────────────────────────────

  Future<List<dynamic>> getHospitals({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null) params['search'] = search;
    final res = await _dio.get('/hospitals/', queryParameters: params);
    return res.data;
  }

  Future<List<dynamic>> getDoctors(int hospitalId, {String? department}) async {
    final params = <String, dynamic>{};
    if (department != null) params['department'] = department;
    final res = await _dio.get('/hospitals/$hospitalId/doctors', queryParameters: params);
    return res.data;
  }

  Future<List<dynamic>> getOpdSlots(int doctorId, {String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) params['slot_date'] = date;
    final res = await _dio.get('/hospitals/doctors/$doctorId/slots', queryParameters: params);
    return res.data;
  }

  Future<Map<String, dynamic>> bookOpd(int slotId, {bool priority = false}) async {
    final res = await _dio.post('/hospitals/opd/book', data: {
      'slot_id': slotId,
      'is_priority': priority,
    });
    return res.data;
  }

  // ─── Emergency ────────────────────────────────────────────────

  Future<Map<String, dynamic>> triggerEmergency({double? lat, double? lng}) async {
    final params = <String, dynamic>{};
    if (lat != null) params['latitude'] = lat;
    if (lng != null) params['longitude'] = lng;
    final res = await _dio.post('/emergency/alert', queryParameters: params);
    return res.data;
  }

  Future<void> resolveEmergency(int alertId) async {
    await _dio.post('/emergency/alert/$alertId/resolve');
  }

  Future<List<dynamic>> getEmergencyContacts() async {
    final res = await _dio.get('/emergency/contacts');
    return res.data;
  }

  // ─── Providers ────────────────────────────────────────────────

  Future<Map<String, dynamic>> setPin(String pin) async {
    final res = await _dio.post('/auth/set-pin', data: {'pin': pin});
    return res.data;
  }

  Future<Map<String, dynamic>> voiceEnrol(int sampleNumber, List<int> audioBytes) async {
    final formData = FormData.fromMap({
      'sample_number': sampleNumber,
      'audio': MultipartFile.fromBytes(audioBytes, filename: 'voice_sample.wav'),
    });
    final res = await _dio.post('/auth/voice/enrol', data: formData);
    return res.data;
  }

  Future<Map<String, dynamic>> voiceVerify(String phone, List<int> audioBytes) async {
    final formData = FormData.fromMap({
      'phone': phone,
      'audio': MultipartFile.fromBytes(audioBytes, filename: 'voice_verify.wav'),
    });
    final res = await _dio.post('/auth/voice/verify', data: formData);
    return res.data;
  }

  // ─── Wallet ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWallet() async {
    final res = await _dio.get('/wallet/');
    return res.data;
  }

  Future<Map<String, dynamic>> addFunds(double amount) async {
    final res = await _dio.post('/wallet/add-funds', data: {'amount': amount});
    return res.data;
  }

  // ─── Payments ────────────────────────────────────────────────

  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String method,
    int? bookingId,
    int? opdBookingId,
  }) async {
    final res = await _dio.post('/payments/', data: {
      'amount': amount,
      'method': method,
      if (bookingId != null) 'booking_id': bookingId,
      if (opdBookingId != null) 'opd_booking_id': opdBookingId,
    });
    return res.data;
  }

  // ─── Family ──────────────────────────────────────────────────

  Future<List<dynamic>> getLinkedSeniors() async {
    final res = await _dio.get('/family/seniors');
    return res.data;
  }

  Future<List<dynamic>> getSeniorActivity(int seniorId) async {
    final res = await _dio.get('/family/seniors/$seniorId/activity');
    return res.data;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
