import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/constants/colors.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// Splash screen is the app entry view. It is referenced by `AppRoutes.splash`
/// and should perform lightweight startup work (branding, preloading, nav).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    // Wait for 2 seconds to show the splash
    await Future.delayed(const Duration(seconds: 200));
    
    if (mounted) {
      // TODO: Check if user is already authenticated
      // For now, always go to onboarding
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: BrutCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('QuizSnap', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'AI-powered quizzes from your documents',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Loading indicator
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

