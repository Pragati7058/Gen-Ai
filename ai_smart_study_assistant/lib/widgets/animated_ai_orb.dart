import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// An animated, pulsing gradient orb that represents the AI "thinking".
/// Used on the splash screen and the processing screen.
class AnimatedAIOrb extends StatefulWidget {
  final double size;
  final Duration pulseDuration;

  const AnimatedAIOrb({
    super.key,
    this.size = 120,
    this.pulseDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<AnimatedAIOrb> createState() => _AnimatedAIOrbState();
}

class _AnimatedAIOrbState extends State<AnimatedAIOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.pulseDuration,
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween(begin: 1.0, end: 1.18).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  late final Animation<double> _opacity =
      Tween(begin: 0.55, end: 0.9).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                  ),
                ),
              ),
              // Pulsing core
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: widget.size / 2.2,
                  height: widget.size / 2.2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFDFE6FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Sparkles
              const _Sparkle(top: 6, left: 22, size: 6),
              const _Sparkle(bottom: 8, right: 18, size: 5),
              const _Sparkle(top: 30, right: 8, size: 4),
            ],
          ),
        );
      },
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;

  const _Sparkle({this.top, this.bottom, this.left, this.right, required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
