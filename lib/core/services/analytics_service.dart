import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

///  service for leaderboards 
/// Handles   rankings, friend comparisons, 
class AnalyticsService {
  /// Get global leaderboard rankings
  static Future<List<LeaderboardEntryModel>> getGlobalLeaderboard({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await ApiService.get(
        ApiEndpoints.getGlobalLeaderboard,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final leaderboardJson = data['leaderboard'] as List<dynamic>;
        return leaderboardJson
            .map((json) => LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get global leaderboard error: $e');
    }
    return [];
  }

  /// Get friends leaderboard rankings
  static Future<List<LeaderboardEntryModel>> getFriendsLeaderboard() async {
    try {
      final response = await ApiService.get(ApiEndpoints.getFriendsLeaderboard);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final leaderboardJson = data['leaderboard'] as List<dynamic>;
        return leaderboardJson
            .map((json) => LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get friends leaderboard error: $e');
    }
    return [];
  }

   
  static Future<UserAnalyticsModel?> getUserAnalytics() async {
    try {
      final response = await ApiService.get(ApiEndpoints.getUserAnalytics);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserAnalyticsModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Get user analytics error: $e');
    }
    return null;
  }

  /// Get analytics for a specific quiz
  static Future<QuizAnalyticsModel?> getQuizAnalytics(String quizId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.quizAnalyticsById(quizId),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return QuizAnalyticsModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Get quiz analytics error: $e');
    }
    return null;
  }
}

/// Leaderboard entry model (reused from multiplayer_service.dart)
class LeaderboardEntryModel {
  final String userId;
  final String userName;
  final int score;
  final int rank;
  final int timeTaken; // in seconds

  const LeaderboardEntryModel({
    required this.userId,
    required this.userName,
    required this.score,
    required this.rank,
    required this.timeTaken,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      score: json['score'] as int,
      rank: json['rank'] as int,
      timeTaken: json['time_taken'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'score': score,
      'rank': rank,
      'time_taken': timeTaken,
    };
  }
}

/// User analytics model
class UserAnalyticsModel {
  final String userId;
  final int totalQuizzes;
  final int totalQuestions;
  final int correctAnswers;
  final double averageScore;
  final int totalTimePlayed; // in seconds
  final List<String> favoriteTopics;
  final Map<String, int> difficultyBreakdown;
  final DateTime lastActivityAt;

  const UserAnalyticsModel({
    required this.userId,
    required this.totalQuizzes,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.averageScore,
    required this.totalTimePlayed,
    required this.favoriteTopics,
    required this.difficultyBreakdown,
    required this.lastActivityAt,
  });

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsModel(
      userId: json['user_id'] as String,
      totalQuizzes: json['total_quizzes'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      averageScore: (json['average_score'] as num).toDouble(),
      totalTimePlayed: json['total_time_played'] as int,
      favoriteTopics: (json['favorite_topics'] as List<dynamic>).cast<String>(),
      difficultyBreakdown: Map<String, int>.from(json['difficulty_breakdown'] as Map),
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_quizzes': totalQuizzes,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'average_score': averageScore,
      'total_time_played': totalTimePlayed,
      'favorite_topics': favoriteTopics,
      'difficulty_breakdown': difficultyBreakdown,
      'last_activity_at': lastActivityAt.toIso8601String(),
    };
  }

  /// Calculate accuracy percentage
  double get accuracyPercentage {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Get average time per question in seconds
  double get averageTimePerQuestion {
    if (totalQuestions == 0) return 0.0;
    return totalTimePlayed / totalQuestions;
  }
}

/// Quiz analytics model
class QuizAnalyticsModel {
  final String quizId;
  final String title;
  final int totalAttempts;
  final double averageScore;
  final int averageCompletionTime; // in seconds
  final List<QuestionAnalyticsModel> questionAnalytics;
  final Map<String, int> difficultyDistribution;
  final DateTime createdAt;

  const QuizAnalyticsModel({
    required this.quizId,
    required this.title,
    required this.totalAttempts,
    required this.averageScore,
    required this.averageCompletionTime,
    required this.questionAnalytics,
    required this.difficultyDistribution,
    required this.createdAt,
  });

  factory QuizAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return QuizAnalyticsModel(
      quizId: json['quiz_id'] as String,
      title: json['title'] as String,
      totalAttempts: json['total_attempts'] as int,
      averageScore: (json['average_score'] as num).toDouble(),
      averageCompletionTime: json['average_completion_time'] as int,
      questionAnalytics: (json['question_analytics'] as List<dynamic>)
          .map((q) => QuestionAnalyticsModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      difficultyDistribution: Map<String, int>.from(json['difficulty_distribution'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'title': title,
      'total_attempts': totalAttempts,
      'average_score': averageScore,
      'average_completion_time': averageCompletionTime,
      'question_analytics': questionAnalytics.map((q) => q.toJson()).toList(),
      'difficulty_distribution': difficultyDistribution,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Question analytics model
class QuestionAnalyticsModel {
  final String questionId;
  final String question;
  final int totalAttempts;
  final int correctAttempts;
  final Map<String, int> optionSelectionCount;

  const QuestionAnalyticsModel({
    required this.questionId,
    required this.question,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.optionSelectionCount,
  });

  factory QuestionAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnalyticsModel(
      questionId: json['question_id'] as String,
      question: json['question'] as String,
      totalAttempts: json['total_attempts'] as int,
      correctAttempts: json['correct_attempts'] as int,
      optionSelectionCount: Map<String, int>.from(json['option_selection_count'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question': question,
      'total_attempts': totalAttempts,
      'correct_attempts': correctAttempts,
      'option_selection_count': optionSelectionCount,
    };
  }

  /// Calculate success rate percentage
  double get successRate {
    if (totalAttempts == 0) return 0.0;
    return (correctAttempts / totalAttempts) * 100;
  }
}