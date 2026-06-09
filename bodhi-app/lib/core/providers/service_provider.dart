import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class ServiceState {
  final bool isLoading;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> services;
  final String? error;

  const ServiceState({
    this.isLoading = false,
    this.categories = const [],
    this.services = const [],
    this.error,
  });

  ServiceState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? services,
    String? error,
  }) =>
      ServiceState(
        isLoading: isLoading ?? this.isLoading,
        categories: categories ?? this.categories,
        services: services ?? this.services,
        error: error,
      );
}

class ServiceNotifier extends StateNotifier<ServiceState> {
  final ApiService _api;

  ServiceNotifier(this._api) : super(const ServiceState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getServiceCategories();
      state = state.copyWith(
        isLoading: false,
        categories: list.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _err(e));
    }
  }

  Future<void> loadServices(String serviceType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _api.getServices(serviceType);
      state = state.copyWith(
        isLoading: false,
        services: list.cast<Map<String, dynamic>>(),
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

final serviceProvider = StateNotifierProvider<ServiceNotifier, ServiceState>((ref) {
  return ServiceNotifier(ref.read(apiServiceProvider));
});
