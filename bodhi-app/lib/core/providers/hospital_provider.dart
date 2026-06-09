import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class HospitalState {
  final bool isLoading;
  final List<Map<String, dynamic>> hospitals;
  final List<Map<String, dynamic>> doctors;
  final List<Map<String, dynamic>> slots;
  final Map<String, dynamic>? opdBooking;
  final String? error;

  const HospitalState({
    this.isLoading = false,
    this.hospitals = const [],
    this.doctors = const [],
    this.slots = const [],
    this.opdBooking,
    this.error,
  });

  HospitalState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? hospitals,
    List<Map<String, dynamic>>? doctors,
    List<Map<String, dynamic>>? slots,
    Map<String, dynamic>? opdBooking,
    String? error,
  }) =>
      HospitalState(
        isLoading: isLoading ?? this.isLoading,
        hospitals: hospitals ?? this.hospitals,
        doctors: doctors ?? this.doctors,
        slots: slots ?? this.slots,
        opdBooking: opdBooking ?? this.opdBooking,
        error: error,
      );
}

class HospitalNotifier extends StateNotifier<HospitalState> {
  final ApiService _api;

  HospitalNotifier(this._api) : super(const HospitalState());

  Future<void> loadHospitals({String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getHospitals(search: search);
      state = state.copyWith(
        isLoading: false,
        hospitals: list.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  Future<void> loadDoctors(int hospitalId, {String? department}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getDoctors(hospitalId, department: department);
      state = state.copyWith(
        isLoading: false,
        doctors: list.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  Future<void> loadSlots(int doctorId, {String? date}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getOpdSlots(doctorId, date: date);
      state = state.copyWith(
        isLoading: false,
        slots: list.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  Future<Map<String, dynamic>?> bookOpd(int slotId, {bool priority = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.bookOpd(slotId, priority: priority);
      state = state.copyWith(isLoading: false, opdBooking: data);
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
      return null;
    }
  }

  String _err(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['detail']?.toString() ?? 'Network error';
    }
    return e.toString();
  }
}

final hospitalProvider = StateNotifierProvider<HospitalNotifier, HospitalState>((ref) {
  return HospitalNotifier(ref.read(apiServiceProvider));
});
