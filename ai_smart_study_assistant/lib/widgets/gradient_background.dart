import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A full-screen decorative backdrop with a soft AI-inspired gradient and
/// blurred glowing orbs. Wrap any [child] to give it a premium feel.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool includeGlow;

  const GradientBackground({
    super.key,
    required this.child,
    this.includeGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0E0B1A), Color(0xFF181030), Color(0xFF0E0B1A)]
              : const [Color(0xFFF7F6FB), Color(0xFFEFEAFB), Color(0xFFF7F6FB)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (includeGlow)
            Positioned(
              top: -120,
              right: -100,
              child: _GlowOrb(
                size: 280,
                gradient: AppColors.brandGradient,
              ),
            ),
          if (includeGlow)
            Positioned(
              bottom: -140,
              left: -120,
              child: _GlowOrb(
                size: 300,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// A soft, blurred glowing circle used as decoration.
class _GlowOrb extends StatelessWidget {
  final double size;
  final Gradient gradient;

  const _GlowOrb({required this.size, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 80,
          ),
        ],
      ),
    ).withOpacity(0.5);
  }
}

/// Tiny helper extension to apply opacity to a widget chain.
extension _OpacityWrap on Widget {
  Widget withOpacity(double value) => Opacity(opacity: value, child: this);
}