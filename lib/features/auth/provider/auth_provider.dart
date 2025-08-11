import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';

class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final bool isAuthenticated;
  final bool? isProfileComplete;
  final String? pendingEmailForOtp;

  const AuthState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isAuthenticated,
    this.isProfileComplete,
    this.pendingEmailForOtp,
  });

  factory AuthState.initial() => const AuthState(
        isLoading: false,
        error: null,
        user: null,
        isAuthenticated: false,
        pendingEmailForOtp: null,
      );

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
    bool? isAuthenticated,
    bool? clearError,
    bool? isProfileComplete,
    String? pendingEmailForOtp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError == true ? null : (error ?? this.error),
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      pendingEmailForOtp: pendingEmailForOtp ?? this.pendingEmailForOtp,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final access = await _storage.read(key: SecureStorageKeys.accessToken);
      if (access != null && access.isNotEmpty) {
        ApiService.setAuthToken(access);
        final user = await AuthService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isProfileComplete: user?.isProfileComplete,
        );
      }
    } on MissingPluginException {
      // Secure storage not available (e.g., during hot reload or unsupported platform)
      return;
    } catch (e) {
      // Swallow unexpected errors to avoid crashing app startup
      if (kDebugMode) {
        // Optional: log once if needed
      }
    }
  }

  Future<AuthResult> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await AuthService.login(email: email, password: password);
    if (result.isSuccess) {
      await _persistTokens(result.tokens);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isProfileComplete: result.isProfileComplete,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
    }
    return result;
  }

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await AuthService.signup(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
    state = state.copyWith(isLoading: false);
    if (!result.isSuccess && !result.isPending) {
      state = state.copyWith(error: result.message);
    } else if (result.isPending) {
      state = state.copyWith(pendingEmailForOtp: email);
    }
    return result;
  }

  Future<AuthResult> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await AuthService.verifyOtp(email: email, otp: otp);
    if (result.isSuccess) {
      await _persistTokens(result.tokens);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: result.user,
        isProfileComplete: result.isProfileComplete,
      );
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
    }
    return result;
  }

  Future<AuthResult> resendOtp({required String email}) async {
    return AuthService.resendOtp(email: email);
  }

  Future<AuthResult> forgotPassword({required String email}) async {
    final res = await AuthService.forgotPassword(email: email);
    if (res.isPending) {
      state = state.copyWith(pendingEmailForOtp: email);
    }
    return res;
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return AuthService.resetPassword(email: email, otp: otp, newPassword: newPassword);
  }

  Future<void> logout() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
    await _storage.delete(key: SecureStorageKeys.refreshToken);
    await AuthService.logout();
    state = AuthState.initial();
  }

  void setPendingEmailForOtp(String? email) {
    state = state.copyWith(pendingEmailForOtp: email);
  }

  Future<void> _persistTokens(AuthTokens? tokens) async {
    if (tokens == null) return;
    if (tokens.accessToken != null) {
      await _storage.write(key: SecureStorageKeys.accessToken, value: tokens.accessToken);
      ApiService.setAuthToken(tokens.accessToken!);
    }
    if (tokens.refreshToken != null) {
      await _storage.write(key: SecureStorageKeys.refreshToken, value: tokens.refreshToken);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
