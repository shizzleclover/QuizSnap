import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/token_manager.dart';

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
  final String? redirectTo; // Where to redirect when profile is incomplete
  final AuthMeStatus? authStatus; // Current auth/me status

  const AuthState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isAuthenticated,
    this.isProfileComplete,
    this.pendingEmailForOtp,
    this.redirectTo,
    this.authStatus,
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
    String? redirectTo,
    AuthMeStatus? authStatus,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError == true ? null : (error ?? this.error),
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      pendingEmailForOtp: pendingEmailForOtp ?? this.pendingEmailForOtp,
      redirectTo: redirectTo ?? this.redirectTo,
      authStatus: authStatus ?? this.authStatus,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      if (kDebugMode) {
        print('=== AuthNotifier._restoreSession ===');
      }
      
      final hasTokens = await TokenManager.loadTokens();
      
      if (kDebugMode) {
        print('Tokens loaded: $hasTokens');
        await TokenManager.debugTokenState('After session restore');
      }
      
      if (hasTokens) {
        await checkAuthStatus();
      } else {
        if (kDebugMode) {
          print('No tokens found - user not authenticated');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Session restore error: $e');
      }
    }
  }

  /// Check authentication status and handle profile completion
  Future<void> checkAuthStatus() async {
    try {
      if (kDebugMode) {
        print('AuthProvider.checkAuthStatus - Starting...');
        print('AuthProvider.checkAuthStatus - Current API token: ${ApiService.authToken != null ? 'Present' : 'Missing'}');
      }
      final result = await AuthService.getCurrentUser();
      if (kDebugMode) {
        print('AuthProvider.checkAuthStatus - Result status: ${result.status}');
      }
      
      switch (result.status) {
        case AuthMeStatus.complete:
          state = state.copyWith(
            isAuthenticated: true,
            user: result.user,
            isProfileComplete: true,
            authStatus: AuthMeStatus.complete,
            redirectTo: null,
          );
          break;
          
        case AuthMeStatus.incomplete:
          state = state.copyWith(
            isAuthenticated: true,
            user: result.user,
            isProfileComplete: false,
            authStatus: AuthMeStatus.incomplete,
            redirectTo: result.redirectTo,
          );
          break;
          
        case AuthMeStatus.unauthenticated:
          await logout();
          state = state.copyWith(
            authStatus: AuthMeStatus.unauthenticated,
          );
          break;
          
        case AuthMeStatus.error:
          state = state.copyWith(
            error: result.errorMessage,
            authStatus: AuthMeStatus.error,
          );
          break;
      }
    } catch (e) {
      if (kDebugMode) print('Auth status check error: $e');
      state = state.copyWith(
        error: 'Failed to check authentication status',
        authStatus: AuthMeStatus.error,
      );
    }
  }

  Future<AuthResult> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    if (kDebugMode) {
      print('=== AuthNotifier.login ===');
    }
    
    final result = await AuthService.login(email: email, password: password);
    
    if (result.isSuccess) {
      if (kDebugMode) {
        print('Login successful');
        await TokenManager.debugTokenState('After login');
      }
      
      // Always check auth status after successful login to get latest state
      await checkAuthStatus();
      state = state.copyWith(isLoading: false);
    } else {
      if (kDebugMode) {
        print('Login failed: ${result.message}');
      }
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
    
    if (kDebugMode) {
      print('=== AuthNotifier.verifyOtp ===');
    }
    
    final result = await AuthService.verifyOtp(email: email, otp: otp);
    
    if (result.isSuccess) {
      if (kDebugMode) {
        print('OTP verification successful');
        await TokenManager.debugTokenState('After OTP verification');
      }
      
      // Always check auth status after successful OTP to get latest state
      await checkAuthStatus();
      state = state.copyWith(isLoading: false);
    } else {
      if (kDebugMode) {
        print('OTP verification failed: ${result.message}');
      }
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
    if (kDebugMode) {
      print('=== AuthNotifier.logout ===');
    }
    
    await TokenManager.clearTokens();
    await AuthService.logout();
    state = AuthState.initial();
    
    if (kDebugMode) {
      print('Logout complete');
    }
  }

  void setPendingEmailForOtp(String? email) {
    state = state.copyWith(pendingEmailForOtp: email);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
