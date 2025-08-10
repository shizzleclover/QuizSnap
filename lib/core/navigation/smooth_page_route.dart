import 'package:flutter/material.dart';

/// Custom page route with smooth slide transitions for bottom navigation.
/// Provides more natural navigation feel compared to default transitions.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String routeName;

  SmoothPageRoute({
    required this.child,
    required this.routeName,
    super.settings,
  }        ) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition from bottom for bottom nav navigation
            const begin = Offset(0.0, 0.1);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            // Fade transition combined with slide
            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
            ));

            var slideAnimation = animation.drive(tween);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Route generator that uses smooth transitions for main app screens
class SmoothRouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return SmoothPageRoute(
      child: _getPageForRoute(settings.name ?? ''),
      routeName: settings.name ?? '',
      settings: settings,
    );
  }

  static Widget _getPageForRoute(String routeName) {
    // This will be handled by the main app router
    // Just return a placeholder for now
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}