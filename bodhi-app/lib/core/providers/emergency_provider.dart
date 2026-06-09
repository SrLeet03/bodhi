import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class EmergencyState {
  final bool isLoading;
  final Map<String, dynamic>? activeAlert;
  final List<Map<String, dynamic>> contacts;
  final String? error;

  const EmergencyState({
    this.isLoading = false,
    this.activeAlert,
    this.contacts = const [],
    this.error,
  });

  EmergencyState copyWith({
    bool? isLoading,
    Map<String, dynamic>? activeAlert,
    List<Map<String, dynamic>>? contacts,
    String? error,
  }) =>
      EmergencyState(
        isLoading: isLoading ?? this.isLoading,
        activeAlert: activeAlert ?? this.activeAlert,
        contacts: contacts ?? this.contacts,
        error: error,
      );
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  final ApiService _api;

  EmergencyNotifier(this._api) : super(const EmergencyState());

  Future<Map<String, dynamic>?> triggerAlert({double? lat, double? lng}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.triggerEmergency(lat: lat, lng: lng);
      state = state.copyWith(isLoading: false, activeAlert: data);
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
      return null;
    }
  }

  Future<bool> resolveAlert(int alertId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.resolveEmergency(alertId);
      state = state.copyWith(isLoading: false, activeAlert: null);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
      return false;
    }
  }

  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getEmergencyContacts();
      state = state.copyWith(
        isLoading: false,
        contacts: list.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  String _err(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['detail']?.toString() ?? 'Network error';
    }
    return e.toString();
  }
}

final emergencyProvider = StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  return EmergencyNotifier(ref.read(apiServiceProvider));
});
