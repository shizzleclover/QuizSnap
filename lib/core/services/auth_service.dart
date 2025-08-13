import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';
import 'token_manager.dart';

/// Authentication service for user login, registration, and session management.
/// Handles all auth-related API calls and token management.
class AuthService {
  /// Try to extract tokens from arbitrary response shapes.
  /// Supports tokens at top-level, in `data`, in `tokens`, and common key names.
  static Map<String, String?> _extractTokens(Map<String, dynamic> raw) {
    String? accessToken;
    String? refreshToken;

    // Helper to probe a map with common key variants
    String? _findAccess(Map<String, dynamic> m) {
      final candidates = [
        'accessToken', 'access_token', 'token', 'jwt', 'idToken', 'authToken', 'authorization'
      ];
      for (final key in candidates) {
        final v = m[key];
        if (v is String && v.isNotEmpty) {
          return v;
        }
      }
      // Nested `tokens` object using different field names
      if (m['tokens'] is Map<String, dynamic>) {
        final t = m['tokens'] as Map<String, dynamic>;
        final nestedCandidates = [
          'accessToken', 'access_token', 'token', 'jwt', 'access'
        ];
        for (final key in nestedCandidates) {
          final v = t[key];
          if (v is String && v.isNotEmpty) {
            return v;
          }
        }
      }
      return null;
    }

    String? _findRefresh(Map<String, dynamic> m) {
      final candidates = [
        'refreshToken', 'refresh_token', 'refreshJwt', 'refresh'
      ];
      for (final key in candidates) {
        final v = m[key];
        if (v is String && v.isNotEmpty) {
          return v;
        }
      }
      if (m['tokens'] is Map<String, dynamic>) {
        final t = m['tokens'] as Map<String, dynamic>;
        final nestedCandidates = [
          'refreshToken', 'refresh_token', 'refreshJwt', 'refresh'
        ];
        for (final key in nestedCandidates) {
          final v = t[key];
          if (v is String && v.isNotEmpty) {
            return v;
          }
        }
      }
      return null;
    }

    // Candidate maps to search, ordered by likelihood
    final List<Map<String, dynamic>> candidates = [];
    candidates.add(raw);
    if (raw['tokens'] is Map<String, dynamic>) candidates.add(raw['tokens'] as Map<String, dynamic>);
    if (raw['data'] is Map<String, dynamic>) {
      final data = raw['data'] as Map<String, dynamic>;
      candidates.add(data);
      if (data['tokens'] is Map<String, dynamic>) candidates.add(data['tokens'] as Map<String, dynamic>);
      if (data['data'] is Map<String, dynamic>) {
        final inner = data['data'] as Map<String, dynamic>;
        candidates.add(inner);
        if (inner['tokens'] is Map<String, dynamic>) candidates.add(inner['tokens'] as Map<String, dynamic>);
      }
      if (data['auth'] is Map<String, dynamic>) {
        final auth = data['auth'] as Map<String, dynamic>;
        candidates.add(auth);
        if (auth['tokens'] is Map<String, dynamic>) candidates.add(auth['tokens'] as Map<String, dynamic>);
      }
      if (data['session'] is Map<String, dynamic>) {
        final session = data['session'] as Map<String, dynamic>;
        candidates.add(session);
      }
      if (data['user'] is Map<String, dynamic>) {
        final user = data['user'] as Map<String, dynamic>;
        candidates.add(user);
      }
    }

    for (final m in candidates) {
      accessToken ??= _findAccess(m);
      refreshToken ??= _findRefresh(m);
      if (accessToken != null) break;
    }

    if (kDebugMode) {
      // Do not print the tokens themselves; only presence
      print('Token extraction - access present: ${accessToken != null}');
      print('Token extraction - refresh present: ${refreshToken != null}');
    }

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
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

        if (kDebugMode) {
          print('=== Login Response ===');
          print('Raw response keys: ${raw.keys.toList()}');
        }

        // Extract tokens from arbitrary response shapes
        final tokenMap = _extractTokens(raw);
        final String? accessToken = tokenMap['accessToken'];
        final String? refreshToken = tokenMap['refreshToken'];

        if (kDebugMode) {
          print('Extracted access token: ${accessToken != null && accessToken.isNotEmpty}');
          print('Extracted refresh token: ${refreshToken != null && refreshToken.isNotEmpty}');
        }

        // Store tokens using the new TokenManager
        if (accessToken != null && accessToken.isNotEmpty) {
          final stored = await TokenManager.setTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          
          if (kDebugMode) {
            print('Tokens stored successfully: $stored');
            await TokenManager.debugTokenState('After Login Token Storage');
          }
          
          if (!stored) {
            return AuthResult.failure('Failed to store authentication tokens');
          }
        } else {
          if (kDebugMode) {
            print('No access token found in response!');
          }
          return AuthResult.failure('No access token received from server');
        }

        // Try to get user data (top-level or in data.user)
        UserModel? user;
        try {
          if (raw['user'] is Map<String, dynamic>) {
            user = UserModel.fromJson(raw['user'] as Map<String, dynamic>);
          } else if (raw['data'] is Map<String, dynamic>) {
            final dataObject = raw['data'] as Map<String, dynamic>;
            if (dataObject['user'] is Map<String, dynamic>) {
              user = UserModel.fromJson(dataObject['user'] as Map<String, dynamic>);
            }
          }
        } catch (_) {
          // If shape is incomplete, proceed without failing; we'll fetch via /auth/me next
          user = null;
        }

        // Create tokens object for compatibility
        final tokens = AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Determine profile completion - check both top level and data object
        bool isProfileComplete = false;
        if (raw['isProfileComplete'] is bool) {
          isProfileComplete = raw['isProfileComplete'] as bool;
        } else if (raw['data'] is Map<String, dynamic>) {
          final dataObject = raw['data'] as Map<String, dynamic>;
          if (dataObject['isProfileComplete'] is bool) {
            isProfileComplete = dataObject['isProfileComplete'] as bool;
          } else {
            isProfileComplete = user?.isProfileComplete ?? false;
          }
        } else {
          isProfileComplete = user?.isProfileComplete ?? false;
        }

        if (kDebugMode) {
          print('Profile complete status: $isProfileComplete');
          print('=== Login Complete ===');
        }

        return AuthResult.successPartial(
          user: user,
          token: accessToken,
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

        if (kDebugMode) {
          print('=== OTP Verification Response ===');
          print('Raw response keys: ${raw.keys.toList()}');
        }

        // Extract tokens from arbitrary response shapes
        final tokenMap = _extractTokens(raw);
        final String? accessToken = tokenMap['accessToken'];
        final String? refreshToken = tokenMap['refreshToken'];

        if (kDebugMode) {
          print('Extracted access token: ${accessToken != null && accessToken.isNotEmpty}');
          print('Extracted refresh token: ${refreshToken != null && refreshToken.isNotEmpty}');
        }

        // Store tokens using the new TokenManager
        if (accessToken != null && accessToken.isNotEmpty) {
          final stored = await TokenManager.setTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
          
          if (kDebugMode) {
            print('Tokens stored successfully: $stored');
            await TokenManager.debugTokenState('After OTP Token Storage');
          }
          
          if (!stored) {
            return AuthResult.failure('Failed to store authentication tokens');
          }
        } else {
          if (kDebugMode) {
            print('No access token found in response!');
          }
          return AuthResult.failure('No access token received from server');
        }

        // Try to get user data (top-level or in data.user)
        UserModel? user;
        try {
          if (raw['user'] is Map<String, dynamic>) {
            user = UserModel.fromJson(raw['user'] as Map<String, dynamic>);
          } else if (raw['data'] is Map<String, dynamic>) {
            final dataObject = raw['data'] as Map<String, dynamic>;
            if (dataObject['user'] is Map<String, dynamic>) {
              user = UserModel.fromJson(dataObject['user'] as Map<String, dynamic>);
            }
          }
        } catch (_) {
          // If shape is incomplete, proceed without failing; we'll fetch via /auth/me next
          user = null;
        }

        // Create tokens object for compatibility
        final tokens = AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Determine profile completion - check both top level and data object
        bool isProfileComplete = false;
        if (raw['isProfileComplete'] is bool) {
          isProfileComplete = raw['isProfileComplete'] as bool;
        } else if (raw['data'] is Map<String, dynamic>) {
          final dataObject = raw['data'] as Map<String, dynamic>;
          if (dataObject['isProfileComplete'] is bool) {
            isProfileComplete = dataObject['isProfileComplete'] as bool;
          } else {
            isProfileComplete = user?.isProfileComplete ?? false;
          }
        } else {
          isProfileComplete = user?.isProfileComplete ?? false;
        }

        if (kDebugMode) {
          print('Profile complete status: $isProfileComplete');
          print('=== OTP Verification Complete ===');
        }

        return AuthResult.successPartial(
          user: user,
          token: accessToken,
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

  /// Get current user profile with status check
  static Future<AuthMeResult> getCurrentUser() async {
    try {
      if (kDebugMode) {
        print('=== AuthService.getCurrentUser ===');
        await TokenManager.debugTokenState('AuthService.getCurrentUser Start');
      }
      
      // Ensure tokens are synchronized first
      final hasTokens = await TokenManager.synchronizeTokens();
      
      if (!hasTokens || !ApiService.isAuthenticated) {
        if (kDebugMode) {
          print('AuthService.getCurrentUser - No tokens available');
          await TokenManager.debugTokenState('No tokens available');
        }
        return AuthMeResult.unauthenticated();
      }

      if (kDebugMode) {
        print('AuthService.getCurrentUser - Making API call to ${ApiEndpoints.getCurrentUser}');
      }
      final response = await ApiService.get(ApiEndpoints.getCurrentUser);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String?;
        
        if (status == 'complete') {
          // Complete profile - extract user data
          final userData = data['user'] as Map<String, dynamic>? ?? data;
          final user = UserModel.fromJson(userData);
          return AuthMeResult.complete(user: user);
        } else if (status == 'incomplete') {
          // Incomplete profile - extract redirect info
          final redirectTo = data['redirectTo'] as String? ?? '/profile/setup';
          final partialUser = data['user'] != null 
              ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
              : null;
          return AuthMeResult.incomplete(redirectTo: redirectTo, user: partialUser);
        } else {
          // Fallback: try to parse as direct user data for backward compatibility
          try {
            final user = UserModel.fromJson(data);
            final isComplete = user.isProfileComplete;
            return isComplete 
                ? AuthMeResult.complete(user: user)
                : AuthMeResult.incomplete(redirectTo: '/profile/setup', user: user);
          } catch (e) {
            if (kDebugMode) print('Failed to parse user data: $e');
            return AuthMeResult.error('Invalid response format');
          }
        }
      } else if (response.statusCode == 401) {
        ApiService.clearAuthToken();
        return AuthMeResult.unauthenticated();
      } else {
        return AuthMeResult.error('Failed to get user profile');
      }
    } catch (e) {
      if (kDebugMode) print('Get current user error: $e');
      return AuthMeResult.error(e.toString());
    }
  }

  /// Legacy method for backward compatibility
  static Future<UserModel?> getCurrentUserLegacy() async {
    final result = await getCurrentUser();
    return result.user;
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

  /// Success without immediate user payload; caller should fetch /auth/me
  factory AuthResult.successPartial({
    UserModel? user,
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
    // Tolerant parsing across different backend shapes
    final id = (json['id'] ?? json['_id']) as String?;
    final email = json['email'] as String?;

    // Fallbacks for createdAt
    final createdAtRaw = (json['created_at'] ?? json['createdAt']) as String?;
    DateTime createdAt;
    if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Optional last login
    final lastLoginRaw = (json['last_login_at'] ?? json['lastLoginAt']) as String?;
    final lastLoginAt = (lastLoginRaw != null && lastLoginRaw.isNotEmpty)
        ? DateTime.tryParse(lastLoginRaw)
        : null;

    // Booleans with multiple key support
    final isVerified = (json['isVerified'] ?? json['emailVerified']) as bool? ?? false;
    final isComplete = (json['isProfileComplete'] ?? json['profileCompleted']) as bool? ?? false;

    return UserModel(
      id: id ?? 'unknown',
      email: email ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isEmailVerified: isVerified,
      isProfileComplete: isComplete,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
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

/// Result from /auth/me endpoint with status information
class AuthMeResult {
  final AuthMeStatus status;
  final UserModel? user;
  final String? redirectTo;
  final String? errorMessage;

  const AuthMeResult._({
    required this.status,
    this.user,
    this.redirectTo,
    this.errorMessage,
  });

  /// Profile is complete - user can access main app
  factory AuthMeResult.complete({required UserModel user}) {
    return AuthMeResult._(
      status: AuthMeStatus.complete,
      user: user,
    );
  }

  /// Profile is incomplete - redirect to setup
  factory AuthMeResult.incomplete({
    required String redirectTo,
    UserModel? user,
  }) {
    return AuthMeResult._(
      status: AuthMeStatus.incomplete,
      user: user,
      redirectTo: redirectTo,
    );
  }

  /// User is not authenticated - redirect to login
  factory AuthMeResult.unauthenticated() {
    return const AuthMeResult._(
      status: AuthMeStatus.unauthenticated,
    );
  }

  /// Error occurred during request
  factory AuthMeResult.error(String message) {
    return AuthMeResult._(
      status: AuthMeStatus.error,
      errorMessage: message,
    );
  }

  /// Check if profile is complete
  bool get isComplete => status == AuthMeStatus.complete;

  /// Check if profile is incomplete
  bool get isIncomplete => status == AuthMeStatus.incomplete;

  /// Check if user is authenticated
  bool get isAuthenticated => status != AuthMeStatus.unauthenticated;

  /// Check if there was an error
  bool get hasError => status == AuthMeStatus.error;
}

/// Status enum for /auth/me responses
enum AuthMeStatus {
  complete,
  incomplete,
  unauthenticated,
  error,
}