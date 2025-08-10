import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme toggle button that switches between light and dark modes.
/// Uses Riverpod for state management across the app.
/// 
/// **Usage:**
/// ```dart
/// ThemeToggle()
/// ```
/// 
/// **Features:**
/// - Animated icon transition
/// - Persistent theme preference
/// - Neo-brutal styling
/// - Accessibility support
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(isDarkMode),
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme state provider using Riverpod
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

/// Theme notifier that manages light/dark mode state with persistence
class ThemeNotifier extends StateNotifier<bool> {
  static const String _themeKey = 'theme_mode';
  
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    state = isDarkMode;
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, state);
  }

  /// Set specific theme mode
  Future<void> setTheme(bool isDark) async {
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  /// Get current theme mode
  bool get isDarkMode => state;
}