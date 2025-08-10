/// API endpoints for QuizSnap backend services.
/// Based on the official product specification and backend design.
class ApiEndpoints {
  // Authentication & User Management (with OTP)
  static const String signup = '/auth/signup';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String loginOtp = '/auth/login-otp'; // 2FA login (optional)
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String getCurrentUser = '/auth/me';
  static const String updateProfile = '/auth/me';
  static const String deleteAccount = '/auth/me';

  // Document Upload & Management
  static const String uploadDocument = '/documents/upload';
  static const String getDocuments = '/documents';
  static const String getDocument = '/documents'; // + /{id}
  static const String deleteDocument = '/documents'; // + /{id}

  // AI-Powered MCQ Generation
  static const String generateMcq = '/mcq/generate';
  static const String createManualMcq = '/mcq/manual';
  static const String getMcq = '/mcq'; // + /{quizId}
  static const String updateMcq = '/mcq'; // + /{quizId}
  static const String deleteMcq = '/mcq'; // + /{quizId}

  // Solo Quiz Mode
  static const String startQuizAttempt = '/quiz/attempt';
  static const String submitQuiz = '/quiz/submit';
  static const String getQuizHistory = '/quiz/history';

  // Multiplayer Quiz Mode
  static const String createMultiplayerRoom = '/multiplayer/create';
  static const String joinMultiplayerRoom = '/multiplayer/join';
  static const String startMultiplayerQuiz = '/multiplayer/start';
  static const String getMultiplayerLeaderboard = '/multiplayer/leaderboard';
  // WebSocket endpoint: WS /multiplayer/events

  // Leaderboards & Analytics
  static const String getGlobalLeaderboard = '/leaderboard/global';
  static const String getFriendsLeaderboard = '/leaderboard/friends';
  static const String getUserAnalytics = '/analytics/user';
  static const String getQuizAnalytics = '/analytics/quiz'; // + /{quizId}

  // Notifications
  static const String sendNotification = '/notifications/send'; // Internal/admin
  static const String getNotifications = '/notifications';
  static const String markNotificationRead = '/notifications'; // + /{id}/read

  // Admin Panel (Future Feature)
  static const String adminUsers = '/admin/users';
  static const String adminDeleteUser = '/admin/users'; // + /{id}
  static const String adminAnalytics = '/admin/analytics';

  /// Helper method to build dynamic endpoints with parameters
  static String withId(String endpoint, String id) => '$endpoint/$id';
  
  /// Helper method to build endpoints with query parameters
  static String withQuery(String endpoint, Map<String, dynamic> params) {
    if (params.isEmpty) return endpoint;
    
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    return '$endpoint?$query';
  }

  /// Helper methods to build dynamic endpoints with IDs
  
  /// Build document endpoint with ID
  static String documentById(String documentId) => withId(getDocument, documentId);
  
  /// Build delete document endpoint
  static String deleteDocumentById(String documentId) => withId(deleteDocument, documentId);
  
  /// Build MCQ endpoint with quiz ID
  static String mcqById(String quizId) => withId(getMcq, quizId);
  
  /// Build update MCQ endpoint
  static String updateMcqById(String quizId) => withId(updateMcq, quizId);
  
  /// Build delete MCQ endpoint
  static String deleteMcqById(String quizId) => withId(deleteMcq, quizId);
  
  /// Build quiz analytics endpoint
  static String quizAnalyticsById(String quizId) => withId(getQuizAnalytics, quizId);
  
  /// Build notification read endpoint
  static String markNotificationReadById(String notificationId) => withId(markNotificationRead, notificationId);
  
  /// Build admin delete user endpoint
  static String adminDeleteUserById(String userId) => withId(adminDeleteUser, userId);
}