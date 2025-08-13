import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/document_service.dart';

/// Document state
class DocumentState {
  final bool isLoading;
  final String? error;
  final List<DocumentModel> documents;
  final bool isUploading;
  final double uploadProgress;

  const DocumentState({
    this.isLoading = false,
    this.error,
    this.documents = const [],
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  DocumentState copyWith({
    bool? isLoading,
    String? error,
    List<DocumentModel>? documents,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      documents: documents ?? this.documents,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

/// Document state notifier
class DocumentNotifier extends StateNotifier<DocumentState> {
  DocumentNotifier() : super(const DocumentState());

  /// Load user documents
  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final documents = await DocumentService.getDocuments();
      state = state.copyWith(
        isLoading: false,
        documents: documents,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Upload document with progress tracking
  Future<bool> uploadDocument({
    required String filePath,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);
    
    try {
      final result = await DocumentService.uploadDocument(
        filePath: filePath,
        metadata: metadata,
      );
      
      if (result.isSuccess && result.document != null) {
        // Add the new document to the list
        final updatedDocuments = [...state.documents, result.document!];
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 1.0,
          documents: updatedDocuments,
        );
        return true;
      } else {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 0.0,
          error: result.message ?? 'Upload failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final result = await DocumentService.deleteDocument(documentId);
      
      if (result.isSuccess) {
        // Remove the document from the list
        final updatedDocuments = state.documents
            .where((doc) => doc.id != documentId)
            .toList();
        state = state.copyWith(documents: updatedDocuments);
        return true;
      } else {
        state = state.copyWith(error: result.message ?? 'Delete failed');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get document by ID with signed URL
  Future<DocumentModel?> getDocument(String documentId) async {
    try {
      return await DocumentService.getDocument(documentId);
    } catch (e) {
      if (kDebugMode) print('Get document error: $e');
      return null;
    }
  }

  /// Update upload progress
  void updateUploadProgress(double progress) {
    state = state.copyWith(uploadProgress: progress);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear all state
  void clear() {
    state = const DocumentState();
  }
}

/// Document provider
final documentProvider = StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  return DocumentNotifier();
});

/// Individual document provider
final documentByIdProvider = FutureProvider.family<DocumentModel?, String>((ref, documentId) async {
  return await ref.read(documentProvider.notifier).getDocument(documentId);
});