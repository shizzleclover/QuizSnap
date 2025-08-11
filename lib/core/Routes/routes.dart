// Deprecated duplicate; kept temporarily. Use core/routes/routes.dart instead.
// This file mirrors constants to avoid breakages during refactor.
// Remove duplicate legacy definition: rely on core/routes/routes.dart

class AppRoutes {
  static const String splash = "/";
  static const String onboarding = "/onboarding";
  
  // Auth routes
  static const String login = "/auth/login";
  static const String signup = "/auth/signup";
  static const String otpConfirmation = "/auth/otp";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
  
  // Main app routes
  static const String home = "/home";
  static const String upload = "/upload";
  static const String soloQuiz = "/solo_quiz";
  static const String multiplayerLobby = "/multiplayer/lobby";
  static const String multiplayerQuiz = "/multiplayer/quiz";
  static const String profile = "/profile";
  static const String profileSetup = "/profile/setup";
}