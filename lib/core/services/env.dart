import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for QuizSnap app.
/// Manages API URLs, keys, and other environment-specific settings.
class Env {
  /// Custom backend API base URL
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  
  /// API version (default: v1)
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  
  /// JWT secret for token validation (if needed for local testing)
  static String? get jwtSecret => dotenv.env['JWT_SECRET'];
  
  /// Upload file size limit (in MB)
  static int get maxUploadSizeMB => int.tryParse(dotenv.env['MAX_UPLOAD_SIZE_MB'] ?? '10') ?? 10;
  
  /// Enable debug logging
  static bool get enableDebugLogging => dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase() == 'true';
  
  /// Timeout duration for API requests (in seconds)
  static int get apiTimeoutSeconds => int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;
  
  /// Environment name (development, staging, production)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  /// Check if running in development mode
  static bool get isDevelopment => environment == 'development';
  
  /// Check if running in production mode
  static bool get isProduction => environment == 'production';
}

