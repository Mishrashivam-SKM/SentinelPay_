// coverage:ignore-file
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final bool withGlow;
  final bool emeraldGlow;
  final double opacity;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.withGlow = false,
    this.emeraldGlow = false,
    this.opacity = 0.04,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (withGlow || emeraldGlow) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            if (emeraldGlow)
              const BoxShadow(
                color: Color(0x264EDEA3),
                blurRadius: 40,
                spreadRadius: 10,
              )
            else if (withGlow)
              const BoxShadow(
                color: Color(0x336366F1),
                blurRadius: 15,
                spreadRadius: 0,
              ),
          ],
        ),
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
