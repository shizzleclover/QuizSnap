import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// Signup screen with email/password registration.
/// Referenced by `AppRoutes.signup`.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // Logo/Title
              Text(
                'QuizSnap',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Signup form
              BrutCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign Up',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      
                      // Email field
                      AppTextField(
                        hint: 'Email',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      AppTextField(
                        hint: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm password field
                      AppTextField(
                        hint: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Signup button
                      PrimaryButton(
                        label: _isLoading ? 'Creating Account...' : 'Sign Up',
                        onPressed: _isLoading ? () {} : _handleSignup,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState?.validate() != true) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // TODO: Implement Supabase authentication
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    
    if (mounted) {
      setState(() => _isLoading = false);
      // TODO: Navigate to OTP confirmation on success
      Navigator.of(context).pushNamed(AppRoutes.otpConfirmation);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}