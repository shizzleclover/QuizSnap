import 'package:flutter/material.dart';
import 'package:quizsnap/features/splash/UI/splash_screen.dart';
import 'package:quizsnap/features/onboarding/UI/onboarding_screen.dart';
import 'package:quizsnap/features/auth/UI/login_screen.dart';
import 'package:quizsnap/features/auth/UI/signup_screen.dart';
import 'package:quizsnap/features/auth/UI/otp_confirmation_screen.dart';
import 'package:quizsnap/features/auth/UI/forgot_password_screen.dart';
import 'package:quizsnap/features/auth/UI/reset_password_screen.dart';
import 'package:quizsnap/features/home/UI/home_screen.dart';
import 'package:quizsnap/features/upload/UI/upload_screen.dart';
import 'package:quizsnap/features/solo_quiz/UI/solo_quiz_screen.dart';
import 'package:quizsnap/features/multiplayer/UI/lobby_screen.dart';
import 'package:quizsnap/features/multiplayer/UI/quiz_screen.dart';
import 'package:quizsnap/features/profile/UI/profile_screen.dart';
import 'package:quizsnap/features/profile/UI/profile_setup_screen.dart';
import '../navigation/smooth_page_route.dart';
import '../routes/routes.dart';

class AppRouter {
  static const _mainAppRoutes = {
    AppRoutes.home,
    AppRoutes.upload,
    AppRoutes.soloQuiz,
    AppRoutes.multiplayerLobby,
    AppRoutes.profile,
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget screen;
    switch (settings.name) {
      // Aliases from backend redirectTo values
      case '/profile-setup':
        screen = const ProfileSetupScreen();
        break;
      // '/home' is already handled by AppRoutes.home
      case AppRoutes.splash:
        screen = const SplashScreen();
        break;
      case AppRoutes.onboarding:
        screen = const OnboardingScreen();
        break;
      case AppRoutes.login:
        screen = const LoginScreen();
        break;
      case AppRoutes.signup:
        screen = const SignupScreen();
        break;
      case AppRoutes.otpConfirmation:
        screen = const OtpConfirmationScreen();
        break;
      case AppRoutes.forgotPassword:
        screen = const ForgotPasswordScreen();
        break;
      case AppRoutes.resetPassword:
        screen = const ResetPasswordScreen();
        break;
      case AppRoutes.home:
        screen = const HomeScreen();
        break;
      case AppRoutes.upload:
        screen = const UploadScreen();
        break;
      case AppRoutes.soloQuiz:
        screen = const SoloQuizScreen();
        break;
      case AppRoutes.multiplayerLobby:
        screen = const MultiplayerLobbyScreen();
        break;
      case AppRoutes.multiplayerQuiz:
        screen = const MultiplayerQuizScreen();
        break;
      case AppRoutes.profile:
        screen = const ProfileScreen();
        break;
      case AppRoutes.profileSetup:
        screen = const ProfileSetupScreen();
        break;
      default:
        screen = const Scaffold(body: Center(child: Text('404 - Not Found')));
    }

    if (_mainAppRoutes.contains(settings.name)) {
      return SmoothPageRoute(child: screen, routeName: settings.name ?? '', settings: settings);
    }

    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }
}