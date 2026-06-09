import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class BookingState {
  final bool isLoading;
  final List<Map<String, dynamic>> bookings;
  final Map<String, dynamic>? activeBooking;
  final String? error;

  const BookingState({
    this.isLoading = false,
    this.bookings = const [],
    this.activeBooking,
    this.error,
  });

  BookingState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? bookings,
    Map<String, dynamic>? activeBooking,
    String? error,
  }) =>
      BookingState(
        isLoading: isLoading ?? this.isLoading,
        bookings: bookings ?? this.bookings,
        activeBooking: activeBooking ?? this.activeBooking,
        error: error,
      );
}

class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _api;

  BookingNotifier(this._api) : super(const BookingState());

  /// Create a new service booking
  Future<Map<String, dynamic>?> createBooking({
    required String serviceType,
    int? serviceId,
    int? seniorId,
    String? scheduledAt,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    String? preferredGender,
    String deliveryMode = 'at_home',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.createBooking({
        'service_type': serviceType,
        if (serviceId != null) 'service_id': serviceId,
        if (seniorId != null) 'senior_id': seniorId,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null) 'notes': notes,
        if (preferredGender != null) 'preferred_gender': preferredGender,
        'delivery_mode': deliveryMode,
      });
      state = state.copyWith(isLoading: false, activeBooking: data);
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
      return null;
    }
  }

  /// Fetch all bookings for current user
  Future<void> loadBookings({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getBookings(status: status);
      state = state.copyWith(
        isLoading: false,
        bookings: list.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  /// Fetch single booking details
  Future<void> loadBooking(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getBooking(id);
      state = state.copyWith(isLoading: false, activeBooking: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  /// Update booking status (provider flow)
  Future<bool> updateStatus(int id, String status, {String? note}) async {
    try {
      await _api.updateBookingStatus(id, status, note: note);
      // Refresh the booking
      await loadBooking(id);
      return true;
    } catch (e) {
      state = state.copyWith(error: _err(e));
      return false;
    }
  }

  /// Verify OTP at arrival
  Future<bool> verifyOtp(int bookingId, String otp) async {
    try {
      await _api.verifyBookingOtp(bookingId, otp);
      return true;
    } catch (e) {
      state = state.copyWith(error: _err(e));
      return false;
    }
  }

  /// Rate completed booking
  Future<bool> rateBooking(int bookingId, int rating, {String? review}) async {
    try {
      await _api.rateBooking(bookingId, rating, review: review);
      return true;
    } catch (e) {
      state = state.copyWith(error: _err(e));
      return false;
    }
  }

  void clearActive() {
    state = state.copyWith(activeBooking: null);
  }

  String _err(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['detail']?.toString() ?? 'Network error';
    }
    return e.toString();
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.read(apiServiceProvider));
});
