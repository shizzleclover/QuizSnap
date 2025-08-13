import 'package:flutter/material.dart';

/// App primary button using global theme defaults. Automatically styled
/// with neo-brutal appearance (bold borders, flat colors, no elevation).
/// 
/// **Usage:**
/// ```dart
/// PrimaryButton(
///   label: 'Sign In',
///   onPressed: () => print('Button pressed'),
/// )
/// ```
/// 
/// **Styling:**
/// - Primary color background from theme
/// - White foreground text
/// - 2px border (from theme configuration)
/// - 6px border radius
/// - 20px horizontal, 14px vertical padding
/// - No elevation (flat design)
/// 
/// **Behavior:**
/// - Disabled state when onPressed is null
/// - Ripple effect on tap
/// - Accessibility support built-in
class PrimaryButton extends StatelessWidget {
  /// Text to display on the button
  final String? label;
  
  /// Alternative text parameter
  final String? text;
  
  /// Icon to display on the button
  final IconData? icon;
  
  /// Callback when button is pressed. Set to null to disable button.
  final VoidCallback? onPressed;
  
  /// Whether to show loading state
  final bool isLoading;

  const PrimaryButton({
    super.key,
    this.label,
    this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = text ?? label ?? '';
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Text(buttonText),
              ],
            ),
    );
  }
}