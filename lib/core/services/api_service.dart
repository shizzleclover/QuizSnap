import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API service for all backend communication.
/// Handles authentication, request/response processing, and error handling.
class ApiService {
  static late Dio _dio;
  static String? _authToken;
  
  /// Base URL for the API
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  
  /// API version
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';
  
  /// Full API URL with version
  static String get apiUrl => '$baseUrl/api';

  /// Initialize the API service with configuration
  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add request/response interceptors for logging and error handling
    _dio.interceptors.add(_createInterceptor());

    if (kDebugMode) {
      print('API Service initialized with base URL: $apiUrl');
    }
  }

  /// Create interceptor for request/response logging and token injection
  static Interceptor _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        if (kDebugMode) {
          print('API Request: ${options.method} ${options.path}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('API Response: ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('API Error: ${error.message}');
          print('Response: ${error.response?.data}');
        }
        handler.next(error);
      },
    );
  }

  /// Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  static void clearAuthToken() {
    _authToken = null;
  }

  /// Get current auth token
  static String? get authToken => _authToken;

  /// Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;

  /// GET request
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors and convert to user-friendly messages
  static ApiException _handleError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = 'Unauthorized. Please log in again.';
              break;
            case 403:
              message = 'Access forbidden. You don\'t have permission.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 422:
              message = error.response?.data['message'] ?? 'Validation error.';
              break;
            case 500:
              message = 'Server error. Please try again later.';
              break;
            default:
              message = 'Something went wrong. Please try again.';
          }
        } else {
          message = 'Network error. Please try again.';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.unknown:
        message = 'Network error. Please check your connection.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    return ApiException(message, statusCode);
  }

  /// Upload file with progress tracking
  static Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    ProgressCallback? onProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalData != null) ...additionalData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}