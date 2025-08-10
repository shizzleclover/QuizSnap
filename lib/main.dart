import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/Routes/app_router.dart';
import 'core/Routes/routes.dart';
import 'core/theme/theme.dart';
import 'core/services/supabase_service.dart';
import 'core/widgets/theme_toggle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App bootstrap: loads .env, initializes Supabase, parses design tokens,
/// builds the theme, then runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.init();
  final tokens = await ThemeLoader.loadTokens('design.json');
  runApp(ProviderScope(child: MainApp(tokens: tokens)));
}

/// Root widget that wires up the global `ThemeData`, responsive baseline
/// via ScreenUtil, and the central router with theme switching support.
class MainApp extends ConsumerWidget {
  final DesignTokens tokens;
  const MainApp({super.key, required this.tokens});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = ThemeLoader.buildTheme(tokens, isDarkMode: isDarkMode);
    final darkTheme = ThemeLoader.buildDarkTheme(tokens);

    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuizSnap',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
