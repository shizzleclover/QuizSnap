import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// OTP confirmation screen for email verification.
/// Referenced by `AppRoutes.otpConfirmation`.
class OtpConfirmationScreen extends StatefulWidget {
  const OtpConfirmationScreen({super.key});

  @override
  State<OtpConfirmationScreen> createState() => _OtpConfirmationScreenState();
}

class _OtpConfirmationScreenState extends State<OtpConfirmationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            
            // Icon
            Icon(
              Icons.email_outlined,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Check your email',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to your email address. Enter it below to verify your account.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // OTP input
            BrutCard(
              child: Column(
                children: [
                  Text(
                    'Enter Verification Code',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // OTP fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => 
                      SizedBox(
                        width: 45,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            
                            if (index == 5 && value.isNotEmpty) {
                              _handleVerifyOtp();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Verify button
                  PrimaryButton(
                    label: _isLoading ? 'Verifying...' : 'Verify',
                    onPressed: _isLoading ? () {} : _handleVerifyOtp,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Resend code
                  if (_canResend)
                    TextButton(
                      onPressed: _handleResendCode,
                      child: const Text('Resend Code'),
                    )
                  else
                    Text(
                      'Resend code in ${_resendCountdown}s',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // TODO: Implement OTP verification with Supabase
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    
    if (mounted) {
      setState(() => _isLoading = false);
      // TODO: Navigate to home on success
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  void _handleResendCode() async {
    // TODO: Implement resend OTP with Supabase
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });
    _startResendTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent!')),
    );
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}