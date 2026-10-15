import 'package:flutter/material.dart';

import '../core/responsive_utils.dart';
import '../core/theme/app_theme.dart';

/// A premium gradient button with a press-down micro-interaction and an
/// optional leading icon. Fully responsive across all screen sizes.
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.height = 56,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final h = AppResponsive.buttonHeight(context);
    final radius = AppResponsive.responsiveRadius(context, min: 14, max: 22);
    final padding = AppResponsive.containerPadding(context);
    final iconSz = AppResponsive.iconSize(context, base: 22);
    final fontSize = AppResponsive.responsiveFontSize(context, min: 13, max: 16);

    final button = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: h,
        width: widget.expanded ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: widget.onPressed == null && !widget.loading
              ? null
              : AppColors.brandGradient,
          color: widget.onPressed == null && !widget.loading
              ? scheme.surfaceContainerHighest
              : null,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            if (widget.onPressed != null || widget.loading)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onTap: widget.loading ? null : widget.onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding.left),
              child: widget.loading
                  ? Center(
                      child: SizedBox(
                        width: iconSz,
                        height: iconSz,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: iconSz),
                          SizedBox(width: padding.left * 0.5),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (widget.expanded) return button;
    return Center(child: button);
  }
}
