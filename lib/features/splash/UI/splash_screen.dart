import 'package:flutter/material.dart';
import 'package:quizsnap/core/routes/routes.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    // Wait briefly to show the splash
    await Future.delayed(const Duration(seconds: 2));
    
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
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/quiz.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            SpinKitFadingCube(
              color: theme.colorScheme.primary,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}