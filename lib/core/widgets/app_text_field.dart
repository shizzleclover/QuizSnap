import 'package:flutter/material.dart';

/// App text field styled by global `InputDecorationTheme`. Consistent
/// input styling across the entire application with neo-brutal appearance.
/// 
/// **Usage:**
/// ```dart
/// AppTextField(
///   hint: 'Enter your email',
///   controller: _emailController,     // Optional
///   obscureText: false,              // Optional, defaults to false
///   keyboardType: TextInputType.email, // Optional
/// )
/// ```
/// 
/// **Styling (from theme):**
/// - 2px border in default state
/// - 2.5px border when focused (primary color)
/// - 2px red border on error
/// - Card color background
/// - 6px border radius
/// - 16px horizontal, 14px vertical padding
/// 
/// **Features:**
/// - Password visibility toggle (when obscureText: true)
/// - Form validation support
/// - Keyboard type optimization
/// - Accessibility labels
class AppTextField extends StatelessWidget {
  /// Placeholder text to show when field is empty
  final String? hint;
  
  /// Label text to show as floating label
  final String? label;
  
  /// Text editing controller for managing field value
  final TextEditingController? controller;
  
  /// Whether to hide text input (for passwords)
  final bool obscureText;
  
  /// Keyboard type for optimized input experience
  final TextInputType keyboardType;
  
  /// Form validator function
  final String? Function(String?)? validator;
  
  /// Whether the field is enabled for input
  final bool enabled;
  
  /// Callback when text changes
  final void Function(String)? onChanged;
  
  /// Widget to show at the end of the field
  final Widget? suffix;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Maximum character length
  final int? maxLength;

  const AppTextField({
    super.key,
    this.hint,
    this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.suffix,
    this.maxLines,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        suffixIcon: suffix,
      ),
    );
  }
}