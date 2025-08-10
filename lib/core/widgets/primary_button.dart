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
  final String label;
  
  /// Callback when button is pressed. Set to null to disable button.
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}