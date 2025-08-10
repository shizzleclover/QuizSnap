import 'package:flutter/material.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// Neo-brutal bottom navigation bar with bold borders and flat design.
/// Used for main app navigation between core features.
/// 
/// **Usage:**
/// ```dart
/// BrutBottomNav(
///   currentRoute: '/home',
///   onTap: (route) => Navigator.pushNamed(context, route),
/// )
/// ```
/// 
/// **Styling:**
/// - Bold top border (2px)
/// - Flat background (no elevation)
/// - Primary color for active items
/// - Muted color for inactive items
/// - Icon + label layout
/// 
/// **Navigation Items:**
/// - Home: Main dashboard
/// - Upload: Document upload
/// - Solo: Solo quiz mode
/// - Multiplayer: Multiplayer lobby
/// - Profile: User profile
class BrutBottomNav extends StatelessWidget {
  /// Current active route to highlight the corresponding nav item
  final String currentRoute;
  
  /// Callback when a navigation item is tapped
  final void Function(String route) onTap;

  const BrutBottomNav({
    super.key,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                route: AppRoutes.home,
                isActive: currentRoute == AppRoutes.home,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.upload_outlined,
                activeIcon: Icons.upload,
                label: 'Upload',
                route: AppRoutes.upload,
                isActive: currentRoute == AppRoutes.upload,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.quiz_outlined,
                activeIcon: Icons.quiz,
                label: 'Solo',
                route: AppRoutes.soloQuiz,
                isActive: currentRoute == AppRoutes.soloQuiz,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Multiplayer',
                route: AppRoutes.multiplayerLobby,
                isActive: currentRoute == AppRoutes.multiplayerLobby,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                route: AppRoutes.profile,
                isActive: currentRoute == AppRoutes.profile,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item with icon and label
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isActive;
  final void Function(String route) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}