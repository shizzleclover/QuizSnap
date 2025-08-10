import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

/// Authentication service for user login, registration, and session management.
/// Handles all auth-related API calls and token management.
class AuthService {
  /// Login with email and password
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);

        // Store auth token
        ApiService.setAuthToken(token);

        return AuthResult.success(user: user, token: token);
      } else {
        return AuthResult.failure('Login failed');
      }
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Register new user (signup with OTP)
  static Future<AuthResult> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'OTP sent to your email. Please verify to activate your account.';
        return AuthResult.pending(message);
      } else {
        return AuthResult.failure('Signup failed');
      }
    } catch (e) {
      if (kDebugMode) print('Signup error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Verify OTP for account activation
  static Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);

        ApiService.setAuthToken(token);
        return AuthResult.success(user: user, token: token);
      } else {
        return AuthResult.failure('OTP verification failed');
      }
    } catch (e) {
      if (kDebugMode) print('OTP verification error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Resend OTP
  static Future<AuthResult> resendOtp({required String email}) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.resendOtp,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'OTP resent to your email';
        return AuthResult.pending(message);
      } else {
        return AuthResult.failure('Failed to resend OTP');
      }
    } catch (e) {
      if (kDebugMode) print('Resend OTP error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// 2FA login with OTP (optional feature)
  static Future<AuthResult> loginWithOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.loginOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user']);

        ApiService.setAuthToken(token);
        return AuthResult.success(user: user, token: token);
      } else {
        return AuthResult.failure('2FA login failed');
      }
    } catch (e) {
      if (kDebugMode) print('2FA login error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Request password reset
  static Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'Password reset email sent';
        return AuthResult.pending(message);
      } else {
        return AuthResult.failure('Failed to send password reset email');
      }
    } catch (e) {
      if (kDebugMode) print('Forgot password error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Reset password with token
  static Future<AuthResult> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return AuthResult.pending('Password reset successful. Please log in.');
      } else {
        return AuthResult.failure('Password reset failed');
      }
    } catch (e) {
      if (kDebugMode) print('Reset password error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Logout user (local logout only, no server endpoint in spec)
  static Future<void> logout() async {
    // Clear local auth token (no logout endpoint in the spec)
    ApiService.clearAuthToken();
  }

  /// Get current user profile
  static Future<UserModel?> getCurrentUser() async {
    try {
      if (!ApiService.isAuthenticated) return null;

      final response = await ApiService.get(ApiEndpoints.getCurrentUser);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Get current user error: $e');
    }
    return null;
  }

  /// Update user profile
  static Future<AuthResult> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await ApiService.put(
        ApiEndpoints.updateProfile,
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(responseData);
        return AuthResult.success(user: user, token: ApiService.authToken ?? '');
      } else {
        return AuthResult.failure('Profile update failed');
      }
    } catch (e) {
      if (kDebugMode) print('Update profile error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Delete user account
  static Future<AuthResult> deleteAccount() async {
    try {
      final response = await ApiService.delete(ApiEndpoints.deleteAccount);

      if (response.statusCode == 200) {
        ApiService.clearAuthToken();
        return AuthResult.pending('Account deleted successfully');
      } else {
        return AuthResult.failure('Account deletion failed');
      }
    } catch (e) {
      if (kDebugMode) print('Delete account error: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => ApiService.isAuthenticated;
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final bool isPending;
  final String? message;
  final UserModel? user;
  final String? token;

  const AuthResult._({
    required this.isSuccess,
    required this.isPending,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResult.success({required UserModel user, required String token}) {
    return AuthResult._(
      isSuccess: true,
      isPending: false,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      isPending: false,
      message: message,
    );
  }

  factory AuthResult.pending(String message) {
    return AuthResult._(
      isSuccess: false,
      isPending: true,
      message: message,
    );
  }
}

/// User model
class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isEmailVerified,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}