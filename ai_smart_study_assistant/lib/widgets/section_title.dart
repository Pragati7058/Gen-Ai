import 'package:flutter/material.dart';

import '../core/responsive_utils.dart';

/// A consistent section heading used across result screens.
/// Fully responsive across all screen sizes.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? icon;
  final Color? color;

  const SectionTitle({super.key, required this.title, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final w = AppResponsive.screenWidth(context);
    final iconSize = AppResponsive.iconSize(context, base: 22);
    final bottomPad = (w * 0.025).clamp(8.0, 14.0);
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: bottomPad),
      child: Row(
        children: [
          if (icon != null) ...[
            Text(icon!, style: TextStyle(fontSize: iconSize)),
            SizedBox(width: w * 0.02),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color ?? scheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
