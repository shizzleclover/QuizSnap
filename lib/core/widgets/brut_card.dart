import 'package:flutter/material.dart';

/// Primitive card with bold border and soft shadow to match the
/// mild neo-brutalism direction. Core building block for content containers.
/// 
/// **Usage:**
/// ```dart
/// BrutCard(
///   child: Text('Content goes here'),
///   padding: EdgeInsets.all(16), // Optional, defaults to 16
///   margin: EdgeInsets.all(8),   // Optional, defaults to 0
/// )
/// ```
/// 
/// **Styling:**
/// - 2px border using theme divider color
/// - 8px border radius
/// - Subtle drop shadow (offset 0,5 with 10px blur)
/// - Surface color from theme
class BrutCard extends StatelessWidget {
  /// The widget to display inside the card
  final Widget child;
  
  /// Internal padding around the child widget
  final EdgeInsetsGeometry padding;
  
  /// External margin around the card
  final EdgeInsetsGeometry margin;

  const BrutCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }
}