import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

/// Document service for file upload and management.
/// Handles document upload, retrieval, and deletion operations.
class DocumentService {
  /// Upload document file
  static Future<DocumentResult> uploadDocument({
    required String filePath,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await ApiService.uploadFile(
        ApiEndpoints.uploadDocument,
        filePath,
        fieldName: 'document',
        additionalData: metadata,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final document = DocumentModel.fromJson(data);
        return DocumentResult.success(document: document);
      } else {
        return DocumentResult.failure('Document upload failed');
      }
    } catch (e) {
      if (kDebugMode) print('Document upload error: $e');
      return DocumentResult.failure(e.toString());
    }
  }

  /// Get user documents list
  static Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await ApiService.get(ApiEndpoints.getDocuments);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final documentsJson = data['documents'] as List<dynamic>;
        return documentsJson
            .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get documents error: $e');
    }
    return [];
  }

  /// Get document by ID with signed URL
  static Future<DocumentModel?> getDocument(String documentId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.documentById(documentId),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return DocumentModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Get document error: $e');
    }
    return null;
  }

  /// Delete document
  static Future<DocumentResult> deleteDocument(String documentId) async {
    try {
      final response = await ApiService.delete(
        ApiEndpoints.deleteDocumentById(documentId),
      );

      if (response.statusCode == 200) {
        return DocumentResult.success();
      } else {
        return DocumentResult.failure('Document deletion failed');
      }
    } catch (e) {
      if (kDebugMode) print('Delete document error: $e');
      return DocumentResult.failure(e.toString());
    }
  }
}

/// Document operation result wrapper
class DocumentResult {
  final bool isSuccess;
  final String? message;
  final DocumentModel? document;

  const DocumentResult._({
    required this.isSuccess,
    this.message,
    this.document,
  });

  factory DocumentResult.success({DocumentModel? document}) {
    return DocumentResult._(
      isSuccess: true,
      document: document,
    );
  }

  factory DocumentResult.failure(String message) {
    return DocumentResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Document model
class DocumentModel {
  final String id;
  final String name;
  final String type;
  final int size;
  final String? signedUrl;
  final DateTime uploadedAt;
  final String userId;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.signedUrl,
    required this.uploadedAt,
    required this.userId,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      signedUrl: json['signed_url'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      'signed_url': signedUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
      'user_id': userId,
    };
  }
}