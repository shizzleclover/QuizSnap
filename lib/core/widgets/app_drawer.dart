import 'package:flutter/material.dart';
import 'package:quizsnap/core/routes/routes.dart';

/// App sidebar drawer with quick access to main features and settings.
/// Provides additional navigation options beyond the bottom nav bar.
/// 
/// **Usage:**
/// ```dart
/// Scaffold(
///   drawer: AppDrawer(currentRoute: AppRoutes.home),
///   // ... rest of scaffold
/// )
/// ```
/// 
/// **Features:**
/// - User profile section
/// - Quick navigation shortcuts
/// - Settings and help links
/// - Recent activity overview
/// - Sign out option
class AppDrawer extends StatelessWidget {
  /// Current route for highlighting active nav item
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Guest User',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'guest@quizsnap.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Dashboard',
                    route: AppRoutes.home,
                    isActive: currentRoute == AppRoutes.home,
                  ),
                  _DrawerItem(
                    icon: Icons.upload_file_outlined,
                    activeIcon: Icons.upload_file,
                    title: 'Upload Document',
                    route: AppRoutes.upload,
                    isActive: currentRoute == AppRoutes.upload,
                  ),
                  _DrawerItem(
                    icon: Icons.quiz_outlined,
                    activeIcon: Icons.quiz,
                    title: 'Solo Quiz',
                    route: AppRoutes.soloQuiz,
                    isActive: currentRoute == AppRoutes.soloQuiz,
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    title: 'Multiplayer',
                    route: AppRoutes.multiplayerLobby,
                    isActive: currentRoute == AppRoutes.multiplayerLobby,
                  ),
                  
                  const Divider(height: 24),
                  
                  // Additional Features
                  _DrawerItem(
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    title: 'Quiz History',
                    route: '/history', // Future route
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quiz history coming soon!')),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark_outline,
                    activeIcon: Icons.bookmark,
                    title: 'Saved Questions',
                    route: '/saved', // Future route
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved questions coming soon!')),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    title: 'Statistics',
                    route: '/stats', // Future route
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statistics coming soon!')),
                      );
                    },
                  ),
                  
                  const Divider(height: 24),
                  
                  // Settings & Support
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: 'Settings',
                    route: AppRoutes.profile,
                    isActive: currentRoute == AppRoutes.profile,
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    activeIcon: Icons.help,
                    title: 'Help & Support',
                    route: '/help', // Future route
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help center coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Sign Out
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: _DrawerItem(
                icon: Icons.logout_outlined,
                activeIcon: Icons.logout,
                title: 'Sign Out',
                route: '',
                isActive: false,
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual drawer navigation item
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String route;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.route,
    required this.isActive,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color getTextColor() {
      if (isDestructive) return theme.colorScheme.error;
      if (isActive) return theme.colorScheme.primary;
      return theme.colorScheme.onSurface;
    }
    
    Color getIconColor() {
      if (isDestructive) return theme.colorScheme.error;
      if (isActive) return theme.colorScheme.primary;
      return theme.colorScheme.onSurface.withValues(alpha: 0.7);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: isActive ? BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ) : null,
      child: ListTile(
        leading: Icon(
          isActive ? activeIcon : icon,
          color: getIconColor(),
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: getTextColor(),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap ?? () {
          Navigator.pop(context); // Close drawer
          if (route.isNotEmpty && !isActive) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}