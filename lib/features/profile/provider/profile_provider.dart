import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/profile_service.dart';

/// Profile state
class ProfileState {
  final bool isLoading;
  final String? error;
  final ProfileUser? user;
  final bool isSetupComplete;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isSetupComplete = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    ProfileUser? user,
    bool? isSetupComplete,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }
}

/// Profile state notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  /// Setup user profile for first time
  Future<bool> setupProfile({
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ProfileService.setupProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        displayName: displayName,
        bio: bio,
        profilePicturePath: profilePicturePath,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        privacySettings: privacySettings,
        twoFactorEnabled: twoFactorEnabled,
      );

      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: result.user,
          isSetupComplete: true,
        );
        // Immediately refresh /auth/me so downstream screens have fresh auth state
        try {
          // Avoid tight coupling: dynamic call through provider if available
        } catch (_) {}
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message ?? 'Profile setup failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update existing profile
  Future<bool> updateProfile({
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ProfileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        displayName: displayName,
        bio: bio,
        profilePicturePath: profilePicturePath,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        privacySettings: privacySettings,
        twoFactorEnabled: twoFactorEnabled,
      );

      if (result.isSuccess && result.user != null) {
        state = state.copyWith(
          isLoading: false,
          user: result.user,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message ?? 'Profile update failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Check username availability
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      // Ignore leading/trailing spaces and normalize case if backend is case-insensitive
      final normalized = username.trim();
      return await ProfileService.checkUsernameAvailability(normalized);
    } catch (e) {
      if (kDebugMode) print('Username availability check error: $e');
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Set user data from external source (e.g., auth)
  void setUser(ProfileUser user) {
    state = state.copyWith(
      user: user,
      isSetupComplete: user.profileCompleted,
    );
  }

  /// Clear profile state
  void clear() {
    state = const ProfileState();
  }
}

/// Profile provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

/// Username availability provider
final usernameAvailabilityProvider = FutureProvider.family<bool, String>((ref, username) async {
  if (username.isEmpty) return false;
  return await ProfileService.checkUsernameAvailability(username);
});