import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizsnap/core/routes/routes.dart';
import '../../../core/services/auth_service.dart';
import '../provider/auth_provider.dart';

/// Login screen redesigned to match provided dark layout.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding),
        ),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Hello there 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Email label
                Text('Email', style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'andrew.ainsley@yourdomain.com',
                    border: const UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),

                // Password label
                Text('Password', style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••••',
                    border: const UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      side: BorderSide(color: theme.dividerColor),
                      activeColor: theme.colorScheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 6),
                    Text('Remember me', style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: theme.dividerColor, height: 1),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _isLoading ? null : _handleLogin,
          child: Text(_isLoading ? 'SIGNING IN...' : 'SIGN IN'),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    final result = await ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.isSuccess) {
      // Let auth provider handle redirection based on auth status
      final authState = ref.read(authProvider);
      String goTo = AppRoutes.home; // Default
      
      if (authState.authStatus == AuthMeStatus.incomplete) {
        // Use redirectTo from auth/me response, fallback to profile setup
        goTo = authState.redirectTo ?? AppRoutes.profileSetup;
      } else if (authState.authStatus == AuthMeStatus.complete) {
        goTo = AppRoutes.home;
      } else {
        // Fallback to checking isProfileComplete for backward compatibility
        goTo = (result.isProfileComplete == false)
            ? AppRoutes.profileSetup
            : AppRoutes.home;
      }
      
      Navigator.of(context).pushReplacementNamed(goTo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Sign in failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}