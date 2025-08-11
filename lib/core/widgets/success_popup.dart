import 'package:flutter/material.dart';

/// Shows a success dialog matching the dark UI style with pill CTA.
Future<void> showSuccessPopup({
  required BuildContext context,
  String title = 'Welcome Back!',
  String message = 'You have successfully reset and created a new password.',
  String buttonText = 'Go to Home',
  VoidCallback? onPressed,
}) async {
  final theme = Theme.of(context);
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: theme.colorScheme.primary, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (onPressed != null) onPressed();
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      );
    },
  );
}

