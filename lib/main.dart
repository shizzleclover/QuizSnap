import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/routes/routes.dart';
import 'core/theme/theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/widgets/theme_toggle.dart';
import 'features/auth/provider/auth_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App bootstrap: loads .env, initializes API service, parses design tokens,
/// builds the theme, then runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  ApiService.init();
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
          home: const AppInitializer(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}

/// App initializer that determines the initial route based on authentication status
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Trigger initialization on first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return;
    
    try {
      if (kDebugMode) {
        print('AppInitializer - Starting auth check...');
        print('AppInitializer - Current API token: ${ApiService.authToken != null ? 'Present' : 'Missing'}');
      }
      // Check auth status using the provider
      await ref.read(authProvider.notifier).checkAuthStatus();
      if (kDebugMode) {
        print('AppInitializer - Auth check completed');
        print('AppInitializer - API token after auth check: ${ApiService.authToken != null ? 'Present' : 'Missing'}');
      }
    } catch (e) {
      if (kDebugMode) print('Auth check error: $e');
    }
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize on first build if not done yet
    if (!_isInitialized) {
      _initializeApp();
    }

    final authState = ref.watch(authProvider);

    // Show splash screen while loading
    if (authState.isLoading || !_isInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate based on auth status (only once)
    if (!_navigated && authState.authStatus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigated || !mounted) return;
        _navigated = true;
        
        final status = authState.authStatus!;
        if (status == AuthMeStatus.complete) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (status == AuthMeStatus.incomplete) {
          Navigator.of(context).pushReplacementNamed(authState.redirectTo ?? AppRoutes.profileSetup);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        }
      });
    }

    // Show loading while waiting for navigation
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
