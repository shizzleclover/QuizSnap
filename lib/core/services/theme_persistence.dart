import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting theme preferences across app sessions.
/// Uses SharedPreferences to store user's theme choice.
class ThemePersistence {
  static const String _themeKey = 'theme_mode';

  /// Save theme preference
  static Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Load theme preference
  static Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default to light mode
  }

  /// Clear theme preference
  static Future<void> clearThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
  }
}