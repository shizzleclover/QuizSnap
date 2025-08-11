import 'package:flutter/material.dart';

/// A simple linear progress indicator styled as a pill.
/// Value must be between 0.0 and 1.0.
class ProgressPill extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final Duration animationDuration;

  const ProgressPill({
    super.key,
    required this.value,
    this.height = 8,
    this.animationDuration = const Duration(milliseconds: 250),
  }) : assert(value >= 0 && value <= 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final barWidth = trackWidth * value.clamp(0, 1);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(height),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: animationDuration,
              width: barWidth,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

