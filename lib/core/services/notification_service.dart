import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

/// Notification service for managing user notifications.
/// Handles quiz invites, OTP emails, reminders, and real-time notifications.
class NotificationService {
  /// Get user notifications
  static Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (unreadOnly != null) queryParams['unread_only'] = unreadOnly;
      if (limit != null) queryParams['limit'] = limit;

      final response = await ApiService.get(
        ApiEndpoints.getNotifications,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final notificationsJson = data['notifications'] as List<dynamic>;
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get notifications error: $e');
    }
    return [];
  }

  /// Mark notification as read
  static Future<NotificationResult> markNotificationRead(String notificationId) async {
    try {
      final response = await ApiService.put(
        ApiEndpoints.markNotificationReadById(notificationId),
        data: {'read': true},
      );

      if (response.statusCode == 200) {
        return NotificationResult.success();
      } else {
        return NotificationResult.failure('Failed to mark notification as read');
      }
    } catch (e) {
      if (kDebugMode) print('Mark notification read error: $e');
      return NotificationResult.failure(e.toString());
    }
  }

  /// Send notification (internal/admin use)
  /// This would typically be called from the backend, not the client
  static Future<NotificationResult> sendNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.sendNotification,
        data: {
          'user_id': userId,
          'title': title,
          'message': message,
          if (type != null) 'type': type,
          if (data != null) 'data': data,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NotificationResult.success();
      } else {
        return NotificationResult.failure('Failed to send notification');
      }
    } catch (e) {
      if (kDebugMode) print('Send notification error: $e');
      return NotificationResult.failure(e.toString());
    }
  }

  /// Mark all notifications as read
  static Future<NotificationResult> markAllNotificationsRead() async {
    try {
      final response = await ApiService.put(
        ApiEndpoints.getNotifications,
        data: {'mark_all_read': true},
      );

      if (response.statusCode == 200) {
        return NotificationResult.success();
      } else {
        return NotificationResult.failure('Failed to mark all notifications as read');
      }
    } catch (e) {
      if (kDebugMode) print('Mark all notifications read error: $e');
      return NotificationResult.failure(e.toString());
    }
  }
}

/// Notification operation result wrapper
class NotificationResult {
  final bool isSuccess;
  final String? message;

  const NotificationResult._({
    required this.isSuccess,
    this.message,
  });

  factory NotificationResult.success() {
    return const NotificationResult._(isSuccess: true);
  }

  factory NotificationResult.failure(String message) {
    return NotificationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Notification model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // quiz_invite, otp, reminder, system
  final bool isRead;
  final Map<String, dynamic>? data; // Additional notification data
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated properties
  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      data: data,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Check if notification is a quiz invite
  bool get isQuizInvite => type == 'quiz_invite';

  /// Check if notification is an OTP
  bool get isOtpNotification => type == 'otp';

  /// Check if notification is a reminder
  bool get isReminder => type == 'reminder';

  /// Check if notification is a system notification
  bool get isSystemNotification => type == 'system';
}