import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// Persisted user session state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final int? userId;
  final String? name;
  final String? role;
  final String? phone;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.name,
    this.role,
    this.phone,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    int? userId,
    String? name,
    String? role,
    String? phone,
    String? error,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        role: role ?? this.role,
        phone: phone ?? this.phone,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AuthState());

  /// Try restoring session from SharedPreferences
  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('auth_name');
    final role = prefs.getString('auth_role');
    final userId = prefs.getInt('auth_user_id');
    final phone = prefs.getString('auth_phone');

    if (token != null && userId != null) {
      _api.setToken(token);
      state = AuthState(
        isAuthenticated: true,
        userId: userId,
        name: name,
        role: role,
        phone: phone,
      );
      return true;
    }
    return false;
  }

  Future<void> _persistSession(Map<String, dynamic> data, {String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['access_token']);
    await prefs.setString('auth_name', data['name']);
    await prefs.setString('auth_role', data['role']);
    await prefs.setInt('auth_user_id', data['user_id']);
    if (phone != null) await prefs.setString('auth_phone', phone);
  }

  /// Step 1: Send OTP to phone
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.sendOtp(phone);
      state = state.copyWith(isLoading: false, phone: phone);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    }
  }

  /// Step 2: Verify OTP → get token
  Future<bool> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.verifyOtp(phone, otp);
      await _persistSession(data, phone: phone);
      state = AuthState(
        isAuthenticated: true,
        userId: data['user_id'],
        name: data['name'],
        role: data['role'],
        phone: phone,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String phone,
    required String name,
    required String role,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.register(
        phone: phone,
        name: name,
        role: role,
        address: address,
      );
      await _persistSession(data, phone: phone);
      state = AuthState(
        isAuthenticated: true,
        userId: data['user_id'],
        name: data['name'],
        role: data['role'],
        phone: phone,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// PIN login
  Future<bool> verifyPin(String phone, String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.verifyPin(phone, pin);
      await _persistSession(data, phone: phone);
      state = AuthState(
        isAuthenticated: true,
        userId: data['user_id'],
        name: data['name'],
        role: data['role'],
        phone: phone,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_name');
    await prefs.remove('auth_role');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_phone');
    state = const AuthState();
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      return e.response?.data?['detail']?.toString() ?? 'Network error';
    }
    return e.toString();
  }
}

// Re-export DioException for the error extractor
import 'package:dio/dio.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});
