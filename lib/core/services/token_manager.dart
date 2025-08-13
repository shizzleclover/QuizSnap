import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

/// Centralized token management with robust persistence and debugging
class TokenManager {
  static const _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Set tokens both in memory (API service) and persistent storage
  static Future<bool> setTokens({
    required String? accessToken,
    String? refreshToken,
  }) async {
    try {
      if (kDebugMode) {
        print('=== TokenManager.setTokens ===');
        print('Access token provided: ${accessToken != null && accessToken.isNotEmpty}');
        print('Refresh token provided: ${refreshToken != null && refreshToken.isNotEmpty}');
      }

      // Set in API service first (for immediate use)
      if (accessToken != null && accessToken.isNotEmpty) {
        ApiService.setAuthToken(accessToken);
        if (kDebugMode) {
          print('Access token set in ApiService: ${ApiService.authToken != null}');
        }

        // Store in secure storage
        await _storage.write(key: _accessTokenKey, value: accessToken);
        if (kDebugMode) {
          print('Access token stored in secure storage');
        }
      }

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        if (kDebugMode) {
          print('Refresh token stored in secure storage');
        }
      }

      // Verify storage worked
      final storedAccess = await _storage.read(key: _accessTokenKey);
      final verified = storedAccess == accessToken;
      
      if (kDebugMode) {
        print('Token storage verification: $verified');
        print('=== TokenManager.setTokens COMPLETE ===');
      }

      return verified;
    } catch (e) {
      if (kDebugMode) {
        print('TokenManager.setTokens ERROR: $e');
      }
      return false;
    }
  }

  /// Load tokens from storage and set in API service
  static Future<bool> loadTokens() async {
    try {
      if (kDebugMode) {
        print('=== TokenManager.loadTokens ===');
      }

      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);

      if (kDebugMode) {
        print('Access token found in storage: ${accessToken != null && accessToken.isNotEmpty}');
        print('Refresh token found in storage: ${refreshToken != null && refreshToken.isNotEmpty}');
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        ApiService.setAuthToken(accessToken);
        if (kDebugMode) {
          print('Access token loaded into ApiService');
          print('ApiService.authToken is now: ${ApiService.authToken != null}');
          print('=== TokenManager.loadTokens SUCCESS ===');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('No valid access token found in storage');
          print('=== TokenManager.loadTokens FAILED ===');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('TokenManager.loadTokens ERROR: $e');
      }
      return false;
    }
  }

  /// Clear all tokens from memory and storage
  static Future<void> clearTokens() async {
    try {
      if (kDebugMode) {
        print('=== TokenManager.clearTokens ===');
      }

      // Clear from API service
      ApiService.clearAuthToken();

      // Clear from storage
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);

      if (kDebugMode) {
        print('All tokens cleared');
        print('=== TokenManager.clearTokens COMPLETE ===');
      }
    } catch (e) {
      if (kDebugMode) {
        print('TokenManager.clearTokens ERROR: $e');
      }
    }
  }

  /// Get current access token from storage (not memory)
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('TokenManager.getAccessToken ERROR: $e');
      }
      return null;
    }
  }

  /// Debug method to check token state
  static Future<void> debugTokenState([String? context]) async {
    if (kDebugMode) {
      final ctx = context != null ? '[$context] ' : '';
      print('${ctx}=== TOKEN STATE DEBUG ===');
      
      // Check memory (API service)
      final memoryToken = ApiService.authToken;
      print('${ctx}Memory (ApiService): ${memoryToken != null ? 'Present (${memoryToken.length} chars)' : 'Missing'}');
      
      // Check storage
      try {
        final storageToken = await _storage.read(key: _accessTokenKey);
        print('${ctx}Storage: ${storageToken != null ? 'Present (${storageToken.length} chars)' : 'Missing'}');
        
        // Check if they match
        if (memoryToken != null && storageToken != null) {
          print('${ctx}Tokens match: ${memoryToken == storageToken}');
        }
      } catch (e) {
        print('${ctx}Storage check failed: $e');
      }
      
      print('${ctx}=== TOKEN STATE DEBUG END ===');
    }
  }

  /// Ensure tokens are synchronized between memory and storage
  static Future<bool> synchronizeTokens() async {
    try {
      if (kDebugMode) {
        print('=== TokenManager.synchronizeTokens ===');
      }

      final storageToken = await _storage.read(key: _accessTokenKey);
      final memoryToken = ApiService.authToken;

      if (storageToken != null && storageToken.isNotEmpty) {
        if (memoryToken != storageToken) {
          // Storage has token but memory doesn't match - restore to memory
          ApiService.setAuthToken(storageToken);
          if (kDebugMode) {
            print('Token restored from storage to memory');
          }
        }
        return true;
      } else if (memoryToken != null && memoryToken.isNotEmpty) {
        // Memory has token but storage doesn't - save to storage
        await _storage.write(key: _accessTokenKey, value: memoryToken);
        if (kDebugMode) {
          print('Token saved from memory to storage');
        }
        return true;
      }

      if (kDebugMode) {
        print('No tokens found in memory or storage');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('TokenManager.synchronizeTokens ERROR: $e');
      }
      return false;
    }
  }
}