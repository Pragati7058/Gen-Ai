import 'package:flutter/material.dart';

import '../core/responsive_utils.dart';

/// A small rounded pill used to show tags like difficulty or duration.
/// Fully responsive across all screen sizes.
class InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const InfoChip({super.key, required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    final w = AppResponsive.screenWidth(context);
    final hPad = (w * 0.028).clamp(8.0, 14.0);
    final vPad = (w * 0.015).clamp(4.0, 8.0);
    final fontSize = AppResponsive.responsiveFontSize(context, min: 10, max: 13);
    final iconSize = AppResponsive.iconSize(context, base: 14);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: accent, size: iconSize),
            SizedBox(width: w * 0.015),
          ],
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
