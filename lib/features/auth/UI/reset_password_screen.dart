import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizsnap/core/routes/routes.dart';
import '../provider/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = ref.watch(authProvider).pendingEmailForOtp ?? '';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset Password',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 8),
                Text('Enter the OTP sent to $email and your new password.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    )),
                const SizedBox(height: 24),

                Text('OTP', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '6-digit code',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length != 6) ? 'Enter 6 digits' : null,
                ),

                const SizedBox(height: 16),
                Text('New Password', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••••',
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().length < 6) ? 'Min 6 characters' : null,
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
          onPressed: _loading ? null : () => _handleReset(email),
          child: const Text('Reset Password'),
        ),
      ),
    );
  }

  Future<void> _handleReset(String email) async {
    if (_formKey.currentState?.validate() != true) return;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing email for reset')),
      );
      return;
    }
    setState(() => _loading = true);
    final res = await ref
        .read(authProvider.notifier)
        .resetPassword(email: email, otp: _otp.text.trim(), newPassword: _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.isPending) {
      // Reset succeeded; route to login
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Reset failed')),
      );
    }
  }
}

