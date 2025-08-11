import 'package:flutter/material.dart';
import 'brut_bottom_nav.dart';
import 'app_drawer.dart';

/// Scaffold wrapper that includes the bottom navigation bar and optional drawer.
/// Use this instead of regular Scaffold for main app screens.
/// 
/// **Usage:**
/// ```dart
/// ScaffoldWithNav(
///   currentRoute: AppRoutes.home,
///   appBar: AppBar(title: Text('Home')),
///   body: YourContent(),
///   hasDrawer: true, // Optional sidebar
/// )
/// ```
/// 
/// **Features:**
/// - Automatic bottom navigation
/// - Optional sidebar drawer
/// - Route-aware highlighting
/// - Smooth navigation transitions
/// - Safe area handling
class ScaffoldWithNav extends StatelessWidget {
  /// Current route for highlighting active nav item
  final String currentRoute;
  
  /// Optional app bar
  final PreferredSizeWidget? appBar;
  
  /// Main content of the screen
  final Widget body;
  
  /// Optional floating action button
  final Widget? floatingActionButton;
  
  /// Background color override
  final Color? backgroundColor;
  
  /// Whether to include the sidebar drawer
  final bool hasDrawer;

  const ScaffoldWithNav({
    super.key,
    required this.currentRoute,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.hasDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: hasDrawer ? AppDrawer(currentRoute: currentRoute) : null,
      body: body,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      bottomNavigationBar: BrutBottomNav(
        currentRoute: currentRoute,
        onTap: (route) {
          // Don't navigate if already on the same route
          if (route != currentRoute) {
            // Replace current to prevent stacking duplicates
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
      ),
    );
  }
}