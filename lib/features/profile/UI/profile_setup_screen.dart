import 'package:flutter/material.dart';
import 'package:quizsnap/core/routes/routes.dart';

/// Profile setup completion placeholder.
/// Add avatar, bio, and preferences here later.
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re all set! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder for additional profile details (avatar, bio, interests).',
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

