import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

/// Quiz service for MCQ generation and quiz operations.
/// Handles quiz creation, solo quiz attempts, and multiplayer functionality.
class QuizService {
  /// Generate MCQs from document
  static Future<QuizResult> generateMcq({
    required String documentId,
    int? numberOfQuestions,
    String? difficulty,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.generateMcq,
        data: {
          'document_id': documentId,
          if (numberOfQuestions != null) 'number_of_questions': numberOfQuestions,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final quiz = QuizModel.fromJson(data);
        return QuizResult.success(quiz: quiz);
      } else {
        return QuizResult.failure('MCQ generation failed');
      }
    } catch (e) {
      if (kDebugMode) print('Generate MCQ error: $e');
      return QuizResult.failure(e.toString());
    }
  }

  /// Create MCQs manually
  static Future<QuizResult> createManualMcq({
    required String title,
    required List<QuestionModel> questions,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.createManualMcq,
        data: {
          'title': title,
          'questions': questions.map((q) => q.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final quiz = QuizModel.fromJson(data);
        return QuizResult.success(quiz: quiz);
      } else {
        return QuizResult.failure('Manual MCQ creation failed');
      }
    } catch (e) {
      if (kDebugMode) print('Create manual MCQ error: $e');
      return QuizResult.failure(e.toString());
    }
  }

  /// Get quiz by ID
  static Future<QuizModel?> getMcq(String quizId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.mcqById(quizId),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return QuizModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Get MCQ error: $e');
    }
    return null;
  }

  /// Update quiz
  static Future<QuizResult> updateMcq({
    required String quizId,
    String? title,
    List<QuestionModel>? questions,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (questions != null) {
        data['questions'] = questions.map((q) => q.toJson()).toList();
      }

      final response = await ApiService.put(
        ApiEndpoints.updateMcqById(quizId),
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final quiz = QuizModel.fromJson(responseData);
        return QuizResult.success(quiz: quiz);
      } else {
        return QuizResult.failure('Quiz update failed');
      }
    } catch (e) {
      if (kDebugMode) print('Update MCQ error: $e');
      return QuizResult.failure(e.toString());
    }
  }

  /// Delete quiz
  static Future<QuizResult> deleteMcq(String quizId) async {
    try {
      final response = await ApiService.delete(
        ApiEndpoints.deleteMcqById(quizId),
      );

      if (response.statusCode == 200) {
        return QuizResult.success();
      } else {
        return QuizResult.failure('Quiz deletion failed');
      }
    } catch (e) {
      if (kDebugMode) print('Delete MCQ error: $e');
      return QuizResult.failure(e.toString());
    }
  }

  /// Start solo quiz attempt
  static Future<QuizAttemptResult> startQuizAttempt({
    required String quizId,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.startQuizAttempt,
        data: {'quiz_id': quizId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final attempt = QuizAttemptModel.fromJson(data);
        return QuizAttemptResult.success(attempt: attempt);
      } else {
        return QuizAttemptResult.failure('Quiz attempt start failed');
      }
    } catch (e) {
      if (kDebugMode) print('Start quiz attempt error: $e');
      return QuizAttemptResult.failure(e.toString());
    }
  }

  /// Submit quiz answers
  static Future<QuizAttemptResult> submitQuiz({
    required String attemptId,
    required Map<String, String> answers, // questionId -> selectedOptionId
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.submitQuiz,
        data: {
          'attempt_id': attemptId,
          'answers': answers,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final result = QuizAttemptModel.fromJson(data);
        return QuizAttemptResult.success(attempt: result);
      } else {
        return QuizAttemptResult.failure('Quiz submission failed');
      }
    } catch (e) {
      if (kDebugMode) print('Submit quiz error: $e');
      return QuizAttemptResult.failure(e.toString());
    }
  }

  /// Get quiz history
  static Future<List<QuizAttemptModel>> getQuizHistory() async {
    try {
      final response = await ApiService.get(ApiEndpoints.getQuizHistory);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final attemptsJson = data['attempts'] as List<dynamic>;
        return attemptsJson
            .map((json) => QuizAttemptModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get quiz history error: $e');
    }
    return [];
  }
}

/// Quiz operation result wrapper
class QuizResult {
  final bool isSuccess;
  final String? message;
  final QuizModel? quiz;

  const QuizResult._({
    required this.isSuccess,
    this.message,
    this.quiz,
  });

  factory QuizResult.success({QuizModel? quiz}) {
    return QuizResult._(
      isSuccess: true,
      quiz: quiz,
    );
  }

  factory QuizResult.failure(String message) {
    return QuizResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Quiz attempt result wrapper
class QuizAttemptResult {
  final bool isSuccess;
  final String? message;
  final QuizAttemptModel? attempt;

  const QuizAttemptResult._({
    required this.isSuccess,
    this.message,
    this.attempt,
  });

  factory QuizAttemptResult.success({QuizAttemptModel? attempt}) {
    return QuizAttemptResult._(
      isSuccess: true,
      attempt: attempt,
    );
  }

  factory QuizAttemptResult.failure(String message) {
    return QuizAttemptResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Quiz model
class QuizModel {
  final String id;
  final String title;
  final List<QuestionModel> questions;
  final DateTime createdAt;
  final String userId;
  final String? documentId;

  const QuizModel({
    required this.id,
    required this.title,
    required this.questions,
    required this.createdAt,
    required this.userId,
    this.documentId,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      documentId: json['document_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'document_id': documentId,
    };
  }
}

/// Question model
class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer; // Index of correct option
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctAnswer: json['correct_answer'] as int,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}

/// Quiz attempt model
class QuizAttemptModel {
  final String id;
  final String quizId;
  final String userId;
  final Map<String, String>? answers;
  final int? score;
  final int? totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? timeTaken; // in seconds

  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.userId,
    this.answers,
    this.score,
    this.totalQuestions,
    required this.startedAt,
    this.completedAt,
    this.timeTaken,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      userId: json['user_id'] as String,
      answers: json['answers'] != null 
          ? Map<String, String>.from(json['answers'] as Map)
          : null,
      score: json['score'] as int?,
      totalQuestions: json['total_questions'] as int?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      timeTaken: json['time_taken'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'answers': answers,
      'score': score,
      'total_questions': totalQuestions,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_taken': timeTaken,
    };
  }
}