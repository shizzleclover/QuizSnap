import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizsnap/core/routes/routes.dart';
import '../../../core/services/auth_service.dart';
import '../provider/auth_provider.dart';

class OtpConfirmationScreen extends ConsumerStatefulWidget {
  const OtpConfirmationScreen({super.key});

  @override
  ConsumerState<OtpConfirmationScreen> createState() => _OtpConfirmationScreenState();
}

class _OtpConfirmationScreenState extends ConsumerState<OtpConfirmationScreen> {
  final List<TextEditingController> _otp = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _resendEnabled = false;
  int _countdown = 60;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    if (_countdown > 0) {
      setState(() => _countdown--);
      _tick();
    } else {
      setState(() => _resendEnabled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signup)
        ),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text("You've got mail ✉️",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  )),
              const SizedBox(height: 8),
              Text(
                'We have sent the OTP verification code to your email address. Check your email and enter the code below.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                )
                
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _otp[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _nodes[i + 1].requestFocus();
                        }
                        if (v.isEmpty && i > 0) {
                          _nodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Center(
                child: _resendEnabled
                    ? TextButton(
                        onPressed: _resend,
                        child: const Text("Resend Code"),
                      )
                    : Text(
                        'You can resend code in $_countdown s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
              ),
              const Spacer(),
            ],
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
          onPressed: _loading ? null : _confirm,
          child: const Text('Confirm'),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final code = _otp.map((e) => e.text).join();
    if (code.length != 6) return;
    setState(() => _loading = true);
    final email = ref.read(authProvider).pendingEmailForOtp ?? '';
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing email for OTP verification')),
      );
      return;
    }
    final result = await ref.read(authProvider.notifier).verifyOtp(email: email, otp: code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      // Let auth provider handle redirection based on auth status
      final authState = ref.read(authProvider);
      String goTo = AppRoutes.home; // Default
      
      if (authState.authStatus == AuthMeStatus.incomplete) {
        // Use redirectTo from auth/me response, fallback to profile setup
        goTo = authState.redirectTo?.replaceFirst('/', '') ?? AppRoutes.profileSetup;
      } else if (authState.authStatus == AuthMeStatus.complete) {
        goTo = AppRoutes.home;
      } else {
        // Fallback to checking isProfileComplete for backward compatibility
        goTo = (result.isProfileComplete == false)
            ? AppRoutes.profileSetup
            : AppRoutes.home;
      }
      
      Navigator.of(context).pushNamedAndRemoveUntil(goTo, (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'OTP verification failed')),
      );
    }
  }

  void _resend() {
    setState(() {
      _resendEnabled = false;
      _countdown = 60;
    });
    _tick();
  }

  @override
  void dispose() {
    for (final c in _otp) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }
}