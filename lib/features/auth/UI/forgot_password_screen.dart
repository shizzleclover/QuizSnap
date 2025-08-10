import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// Forgot password screen for password reset.
/// Referenced by `AppRoutes.forgotPassword`.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            
            // Icon
            Icon(
              _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            
            const SizedBox(height: 32),
            
            if (!_emailSent) ...[
              // Reset form
              Text(
                'Forgot Password?',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              BrutCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reset Password',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      
                      // Email field
                      AppTextField(
                        hint: 'Email',
                        controller: _emailController,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Send reset link button
                      PrimaryButton(
                        label: _isLoading ? 'Sending...' : 'Send Reset Link',
                        onPressed: _isLoading ? () {} : _handleSendResetLink,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Back to login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Remember your password? '),
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
            ] else ...[
              // Email sent confirmation
              Text(
                'Check your email',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a password reset link to ${_emailController.text}',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              BrutCard(
                child: Column(
                  children: [
                    const Text(
                      'Next steps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('1. Check your email inbox'),
                    const SizedBox(height: 8),
                    const Text('2. Click the reset link'),
                    const SizedBox(height: 8),
                    const Text('3. Create a new password'),
                    const SizedBox(height: 24),
                    
                    OutlinedButton(
                      onPressed: _handleSendResetLink,
                      child: const Text('Resend Email'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSendResetLink() async {
    if (!_emailSent && (_formKey.currentState?.validate() != true)) return;
    
    setState(() => _isLoading = true);
    
    // TODO: Implement password reset with Supabase
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}