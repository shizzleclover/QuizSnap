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
        final raw = response.data;
        if (raw is! Map<String, dynamic>) {
          return AuthResult.failure('Unexpected response from server');
        }

        // Accept either nested tokens map or top-level token fields
        final tokensMap = (raw['tokens'] is Map<String, dynamic>)
            ? raw['tokens'] as Map<String, dynamic>
            : <String, dynamic>{
                if (raw['accessToken'] != null) 'accessToken': raw['accessToken'],
                if (raw['refreshToken'] != null) 'refreshToken': raw['refreshToken'],
              };

        final tokens = AuthTokens.fromJson(tokensMap);

        if (tokens.accessToken != null && tokens.accessToken!.isNotEmpty) {
          ApiService.setAuthToken(tokens.accessToken!);
        }

        // Handle user data - either nested or at top level
        UserModel? user;
        if (raw['user'] is Map<String, dynamic>) {
          user = UserModel.fromJson(raw['user'] as Map<String, dynamic>);
        } else {
          // Try to build user from top-level fields, with null safety
          try {
            final userMap = <String, dynamic>{};
            if (raw['id'] != null) userMap['id'] = raw['id'];
            if (raw['email'] != null) userMap['email'] = raw['email'];
            if (raw['firstName'] != null) userMap['firstName'] = raw['firstName'];
            if (raw['lastName'] != null) userMap['lastName'] = raw['lastName'];
            if (raw['phoneNumber'] != null) userMap['phoneNumber'] = raw['phoneNumber'];
            if (raw['isVerified'] != null) userMap['isVerified'] = raw['isVerified'];
            if (raw['isProfileComplete'] != null) userMap['isProfileComplete'] = raw['isProfileComplete'];
            if (raw['created_at'] != null) userMap['created_at'] = raw['created_at'];
            if (raw['last_login_at'] != null) userMap['last_login_at'] = raw['last_login_at'];

            // Only try to create user if we have minimum required fields
            if (userMap['id'] != null && userMap['email'] != null) {
              user = UserModel.fromJson(userMap);
            }
          } catch (e) {
            if (kDebugMode) print('Failed to parse user from top-level fields: $e');
          }
        }

        // If we still don't have user data, try to fetch it
        if (user == null && tokens.accessToken != null) {
          user = await getCurrentUser();
        }

        if (user == null) {
          return AuthResult.failure('Could not load user data after login');
        }

        final isProfileComplete = (raw['isProfileComplete'] is bool)
            ? raw['isProfileComplete'] as bool
            : user.isProfileComplete;

        return AuthResult.success(
          user: user,
          token: tokens.accessToken ?? '',
          tokens: tokens,
          isProfileComplete: isProfileComplete,
        );
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
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'OTP sent to your email/phone.';
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
        final raw = response.data;
        if (raw is! Map<String, dynamic>) {
          return AuthResult.failure('Unexpected response from server');
        }

        final tokensMap = (raw['tokens'] is Map<String, dynamic>)
            ? raw['tokens'] as Map<String, dynamic>
            : <String, dynamic>{
                if (raw['accessToken'] != null) 'accessToken': raw['accessToken'],
                if (raw['refreshToken'] != null) 'refreshToken': raw['refreshToken'],
              };
        final tokens = AuthTokens.fromJson(tokensMap);

        if (tokens.accessToken != null && tokens.accessToken!.isNotEmpty) {
          ApiService.setAuthToken(tokens.accessToken!);
        }

        UserModel? user;
        if (raw['user'] is Map<String, dynamic>) {
          user = UserModel.fromJson(raw['user'] as Map<String, dynamic>);
        } else {
          // Fetch user profile if not included in response
          user = await getCurrentUser();
        }

        if (user == null) {
          return AuthResult.failure('Could not load user after verification');
        }

        final isProfileComplete = (raw['isProfileComplete'] is bool)
            ? raw['isProfileComplete'] as bool
            : user.isProfileComplete;

        return AuthResult.success(
          user: user,
          token: tokens.accessToken ?? '',
          tokens: tokens,
          isProfileComplete: isProfileComplete,
        );
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
        final tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>? ?? {});
        final user = UserModel.fromJson(data['user']);
        final isProfileComplete = data['isProfileComplete'] as bool? ?? true;

        if (tokens.accessToken != null) {
          ApiService.setAuthToken(tokens.accessToken!);
        }
        return AuthResult.success(
          user: user,
          token: tokens.accessToken ?? '',
          tokens: tokens,
          isProfileComplete: isProfileComplete,
        );
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
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
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
  final AuthTokens? tokens;
  final bool? isProfileComplete;

  const AuthResult._({
    required this.isSuccess,
    required this.isPending,
    this.message,
    this.user,
    this.token,
    this.tokens,
    this.isProfileComplete,
  });

  factory AuthResult.success({
    required UserModel user,
    required String token,
    AuthTokens? tokens,
    bool? isProfileComplete,
  }) {
    return AuthResult._(
      isSuccess: true,
      isPending: false,
      user: user,
      token: token,
      tokens: tokens,
      isProfileComplete: isProfileComplete,
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

/// Tokens model
class AuthTokens {
  final String? accessToken;
  final String? refreshToken;

  const AuthTokens({this.accessToken, this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

/// User model
class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.isEmailVerified,
    required this.isProfileComplete,
    required this.createdAt,
    this.lastLoginAt,
  });

  String get fullName =>
      [firstName, lastName].where((e) => (e ?? '').isNotEmpty).join(' ').trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: json['isVerified'] as bool? ?? false,
      isProfileComplete: json['isProfileComplete'] as bool? ?? true,
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
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'isVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}