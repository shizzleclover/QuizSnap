import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

/// Multiplayer service for real-time quiz rooms and competitions.
/// Handles room creation, joining, and multiplayer quiz operations.
class MultiplayerService {
  /// Create a multiplayer room
  static Future<MultiplayerResult> createRoom({
    required String quizId,
    int? maxPlayers,
    String? roomName,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.createMultiplayerRoom,
        data: {
          'quiz_id': quizId,
          if (maxPlayers != null) 'max_players': maxPlayers,
          if (roomName != null) 'room_name': roomName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final room = MultiplayerRoomModel.fromJson(data);
        return MultiplayerResult.success(room: room);
      } else {
        return MultiplayerResult.failure('Room creation failed');
      }
    } catch (e) {
      if (kDebugMode) print('Create room error: $e');
      return MultiplayerResult.failure(e.toString());
    }
  }

  /// Join an existing multiplayer room
  static Future<MultiplayerResult> joinRoom({
    required String roomCode,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.joinMultiplayerRoom,
        data: {'room_code': roomCode},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final room = MultiplayerRoomModel.fromJson(data);
        return MultiplayerResult.success(room: room);
      } else {
        return MultiplayerResult.failure('Failed to join room');
      }
    } catch (e) {
      if (kDebugMode) print('Join room error: $e');
      return MultiplayerResult.failure(e.toString());
    }
  }

  /// Start multiplayer quiz for all players
  static Future<MultiplayerResult> startMultiplayerQuiz({
    required String roomId,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.startMultiplayerQuiz,
        data: {'room_id': roomId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final room = MultiplayerRoomModel.fromJson(data);
        return MultiplayerResult.success(room: room);
      } else {
        return MultiplayerResult.failure('Failed to start multiplayer quiz');
      }
    } catch (e) {
      if (kDebugMode) print('Start multiplayer quiz error: $e');
      return MultiplayerResult.failure(e.toString());
    }
  }

  /// Get multiplayer leaderboard
  static Future<List<LeaderboardEntryModel>> getMultiplayerLeaderboard({
    required String roomId,
  }) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getMultiplayerLeaderboard,
        queryParameters: {'room_id': roomId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final leaderboardJson = data['leaderboard'] as List<dynamic>;
        return leaderboardJson
            .map((json) => LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) print('Get multiplayer leaderboard error: $e');
    }
    return [];
  }
}

/// Multiplayer operation result wrapper
class MultiplayerResult {
  final bool isSuccess;
  final String? message;
  final MultiplayerRoomModel? room;

  const MultiplayerResult._({
    required this.isSuccess,
    this.message,
    this.room,
  });

  factory MultiplayerResult.success({MultiplayerRoomModel? room}) {
    return MultiplayerResult._(
      isSuccess: true,
      room: room,
    );
  }

  factory MultiplayerResult.failure(String message) {
    return MultiplayerResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Multiplayer room model
class MultiplayerRoomModel {
  final String id;
  final String roomCode;
  final String quizId;
  final String hostId;
  final List<String> playerIds;
  final int maxPlayers;
  final String status; // waiting, in_progress, completed
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const MultiplayerRoomModel({
    required this.id,
    required this.roomCode,
    required this.quizId,
    required this.hostId,
    required this.playerIds,
    required this.maxPlayers,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory MultiplayerRoomModel.fromJson(Map<String, dynamic> json) {
    return MultiplayerRoomModel(
      id: json['id'] as String,
      roomCode: json['room_code'] as String,
      quizId: json['quiz_id'] as String,
      hostId: json['host_id'] as String,
      playerIds: (json['player_ids'] as List<dynamic>).cast<String>(),
      maxPlayers: json['max_players'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_code': roomCode,
      'quiz_id': quizId,
      'host_id': hostId,
      'player_ids': playerIds,
      'max_players': maxPlayers,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

/// Leaderboard entry model
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