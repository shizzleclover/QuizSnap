import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizsnap/core/routes/routes.dart';
import 'package:quizsnap/core/widgets/progress_pill.dart';
import '../provider/auth_provider.dart';

/// Signup screen redesigned with dark layout and progress pill.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  bool _submitting = false;
  bool _obscure = true;

  double get _progress {
    int filled = 0;
    if (_firstName.text.trim().isNotEmpty) filled++;
    if (_lastName.text.trim().isNotEmpty) filled++;
    if (_email.text.trim().isNotEmpty) filled++;
    if (_password.text.trim().isNotEmpty) filled++;
    if (_phone.text.trim().isNotEmpty) filled++;
    return filled / 5;
  }

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: ProgressPill(value: _progress),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Create an account ✏️',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please complete your profile.\nDon\'t worry, your data will remain private and only you can see it.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 24),
                _label(context, 'First Name'),
                TextFormField(
                  controller: _firstName,
                  decoration: const InputDecoration(
                    hintText: 'Andrew',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                _label(context, 'Last Name'),
                TextFormField(
                  controller: _lastName,
                  decoration: const InputDecoration(
                    hintText: 'Ainsley',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                _label(context, 'Email'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'andrew.ainsley@yourdomain.com',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),

                const SizedBox(height: 16),
                _label(context, 'Password'),
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : (v.length < 6 ? 'Min 6 characters' : null),
                ),

                const SizedBox(height: 16),
                _label(context, 'Phone Number'),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+1-300-555-0399',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                // Removed Country and Age to match required schema

                const SizedBox(height: 24),
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
          onPressed: _submitting ? null : _continue,
          child: const Text('Continue'),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Future<void> _continue() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submitting = true);
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    final email = _email.text.trim();
    final result = await ref.read(authProvider.notifier).signup(
          email: email,
          password: _password.text,
          firstName: first,
          lastName: last,
          phoneNumber: _phone.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isPending) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.otpConfirmation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Signup failed')),
      );
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }
}