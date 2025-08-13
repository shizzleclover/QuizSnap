import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

/// Profile service for user profile management.
/// Handles profile setup, updates, and profile data operations.
class ProfileService {
  /// Complete first-time profile setup
  static Future<ProfileResult> setupProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String displayName,
    String? bio,
    String? profilePicturePath,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    Map<String, dynamic>? address,
    Map<String, dynamic>? privacySettings,
    bool? twoFactorEnabled,
  }) async {
    try {
      // Normalize inputs
      String _normalizeUsername(String u) => u.trim().toLowerCase();
      String? _normalizeGender(String? g) {
        if (g == null) return null;
        final v = g.trim().toLowerCase().replaceAll(' ', '_');
        return v;
      }

      bool _isNonEmpty(String? v) => v != null && v.trim().isNotEmpty;

      if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        // multipart/form-data: objects and booleans as strings
        final Map<String, dynamic> fields = {};
        void addField(String key, String? value) {
          if (_isNonEmpty(value)) fields[key] = value!.trim();
        }

        addField('firstName', firstName);
        addField('lastName', lastName);
        addField('username', _normalizeUsername(username));
        addField('displayName', displayName);
        addField('bio', bio);
        addField('phoneNumber', phoneNumber);
        addField('dateOfBirth', dateOfBirth);
        addField('gender', _normalizeGender(gender));

        // Address as dotted keys if provided
        if (address != null && address.isNotEmpty) {
          void addAddr(String k) {
            final v = address[k];
            if (v is String && v.trim().isNotEmpty) {
              fields['address.$k'] = v.trim();
            }
          }
          addAddr('line1');
          addAddr('line2');
          addAddr('city');
          addAddr('state');
          addAddr('country');
          addAddr('postalCode');
        }

        // privacySettings as JSON string
        if (privacySettings != null && privacySettings.isNotEmpty) {
          fields['privacySettings'] = jsonEncode(privacySettings);
        }

        // twoFactorEnabled as string "true"/"false"
        if (twoFactorEnabled != null) {
          fields['twoFactorEnabled'] = twoFactorEnabled.toString();
        }

        // Attach file
        fields['profilePicture'] = await MultipartFile.fromFile(profilePicturePath);

        final formData = FormData.fromMap(fields);

        final response = await ApiService.post(
          ApiEndpoints.profileSetup,
          data: formData,
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final userData = (data['data'] is Map<String, dynamic>)
              ? (data['data']['user'] as Map<String, dynamic>)
              : (data['user'] as Map<String, dynamic>);
          final user = ProfileUser.fromJson(userData);
          return ProfileResult.success(user: user, message: data['message'] as String?);
        } else {
          return ProfileResult.failure('Profile setup failed');
        }
      } else {
        // application/json: nested objects allowed; booleans as proper booleans
        final Map<String, dynamic> body = {};
        void addField(String key, String? value) {
          if (_isNonEmpty(value)) body[key] = value!.trim();
        }

        addField('firstName', firstName);
        addField('lastName', lastName);
        addField('username', _normalizeUsername(username));
        addField('displayName', displayName);
        addField('bio', bio);
        addField('phoneNumber', phoneNumber);
        addField('dateOfBirth', dateOfBirth);
        addField('gender', _normalizeGender(gender));

        if (address != null) {
          // Remove empties from address
          final filtered = <String, dynamic>{};
          address.forEach((k, v) {
            if (v is String && v.trim().isNotEmpty) filtered[k] = v.trim();
          });
          if (filtered.isNotEmpty) body['address'] = filtered;
        }

        if (privacySettings != null && privacySettings.isNotEmpty) {
          body['privacySettings'] = privacySettings;
        }

        if (twoFactorEnabled != null) {
          body['twoFactorEnabled'] = twoFactorEnabled;
        }

        final response = await ApiService.post(
          ApiEndpoints.profileSetup,
          data: body,
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final userData = (data['data'] is Map<String, dynamic>)
              ? (data['data']['user'] as Map<String, dynamic>)
              : (data['user'] as Map<String, dynamic>);
          final user = ProfileUser.fromJson(userData);
          return ProfileResult.success(user: user, message: data['message'] as String?);
        } else if (response.statusCode == 400) {
          return ProfileResult.failure('Username is already taken or validation error');
        } else {
          return ProfileResult.failure('Profile setup failed');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Profile setup error: $e');
      return ProfileResult.failure(e.toString());
    }
  }

  /// Update existing profile
  static Future<ProfileResult> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? displayName,
    String? bio,
    String? profilePicturePath,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    Map<String, dynamic>? address,
    Map<String, dynamic>? privacySettings,
    bool? twoFactorEnabled,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (username != null) data['username'] = username;
      if (displayName != null) data['displayName'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
      if (gender != null) data['gender'] = gender;
      if (address != null) data['address'] = address;
      if (privacySettings != null) data['privacySettings'] = privacySettings;
      if (twoFactorEnabled != null) data['twoFactorEnabled'] = twoFactorEnabled;

      // Handle profile picture separately if provided
      FormData? formData;
      if (profilePicturePath != null) {
        formData = FormData.fromMap({
          ...data,
          'profilePicture': await MultipartFile.fromFile(profilePicturePath),
        });
      }

      final response = await ApiService.put(
        ApiEndpoints.updateProfile,
        data: formData ?? data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final user = ProfileUser.fromJson(responseData);
        return ProfileResult.success(user: user);
      } else {
        return ProfileResult.failure('Profile update failed');
      }
    } catch (e) {
      if (kDebugMode) print('Profile update error: $e');
      return ProfileResult.failure(e.toString());
    }
  }

  /// Check if username is available
  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await ApiService.get(
        '/profile/check-username',
        queryParameters: {'username': username},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Accept a variety of shapes from backend
          if (data['available'] is bool) return data['available'] as bool;
          if (data['isAvailable'] is bool) return data['isAvailable'] as bool;
          if (data['data'] is Map<String, dynamic>) {
            final nested = data['data'] as Map<String, dynamic>;
            if (nested['available'] is bool) return nested['available'] as bool;
            if (nested['isAvailable'] is bool) return nested['isAvailable'] as bool;
          }
          if (data['exists'] is bool) return !(data['exists'] as bool);
          if (data['taken'] is bool) return !(data['taken'] as bool);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Username check error: $e');
      // Network/parse issues: don't block user; we'll rely on server-side validation
    }
    // Default to true so we don't incorrectly block the user
    return true;
  }
}

/// Profile operation result wrapper
class ProfileResult {
  final bool isSuccess;
  final String? message;
  final ProfileUser? user;

  const ProfileResult._({
    required this.isSuccess,
    this.message,
    this.user,
  });

  factory ProfileResult.success({ProfileUser? user, String? message}) {
    return ProfileResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory ProfileResult.failure(String message) {
    return ProfileResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Enhanced user model for profile management
class ProfileUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String displayName;
  final String? bio;
  final ProfilePicture? profilePicture;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? privacySettings;
  final bool profileCompleted;
  final bool isNewUser;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const ProfileUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.displayName,
    this.bio,
    this.profilePicture,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.privacySettings,
    required this.profileCompleted,
    required this.isNewUser,
    required this.twoFactorEnabled,
    required this.createdAt,
    this.lastLoginAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      profilePicture: json['profilePicture'] != null 
          ? ProfilePicture.fromJson(json['profilePicture'] as Map<String, dynamic>)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as Map<String, dynamic>?,
      privacySettings: json['privacySettings'] as Map<String, dynamic>?,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      isNewUser: json['isNewUser'] as bool? ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
      lastLoginAt: json['last_login_at'] != null || json['lastLoginAt'] != null
          ? DateTime.parse(json['last_login_at'] as String? ?? json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'profilePicture': profilePicture?.toJson(),
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'privacySettings': privacySettings,
      'profileCompleted': profileCompleted,
      'isNewUser': isNewUser,
      'twoFactorEnabled': twoFactorEnabled,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

/// Profile picture model
class ProfilePicture {
  final String fileName;
  final String supabaseUrl;

  const ProfilePicture({
    required this.fileName,
    required this.supabaseUrl,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    return ProfilePicture(
      fileName: json['fileName'] as String,
      supabaseUrl: json['supabaseUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'supabaseUrl': supabaseUrl,
    };
  }
}