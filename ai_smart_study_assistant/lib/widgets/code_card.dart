import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/responsive_utils.dart';
import '../core/theme/app_theme.dart';

/// A dark, syntax-style card that displays code with a copy button.
class CodeCard extends StatelessWidget {
  final String title;
  final String language;
  final String code;
  final List<String> widgetsUsed;

  const CodeCard({
    super.key,
    required this.title,
    required this.language,
    required this.code,
    this.widgetsUsed = const [],
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied to clipboard ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlighted = _highlight(code);
    final radius = AppResponsive.responsiveRadius(context, min: 14, max: 20);
    final padding = AppResponsive.innerPadding(context);
    final codeFont = AppResponsive.responsiveFontSize(context, min: 11, max: 13);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: const Color(0xFF12102B),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(padding.left),
            child: Text.rich(
              highlighted,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: codeFont,
                height: 1.55,
                color: const Color(0xFFE6E1FF),
              ),
            ),
          ),
          if (widgetsUsed.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(padding.left, 0, padding.left, padding.bottom),
              child: Wrap(
                spacing: AppResponsive.gapWidth(context, base: 6),
                runSpacing: AppResponsive.gapWidth(context, base: 6),
                children: widgetsUsed
                    .map((w) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: padding.left * 0.8,
                              vertical: padding.bottom * 0.6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            w,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: codeFont - 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final w = AppResponsive.screenWidth(context);
    final pad = AppResponsive.innerPadding(context);
    final fontSize = AppResponsive.responsiveFontSize(context, min: 11, max: 13);
    final dotSize = (w * 0.025).clamp(8.0, 12.0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: pad.left, vertical: pad.top * 0.8),
      color: const Color(0xFF1A1740),
      child: Row(
        children: [
          _Dot(color: const Color(0xFFFF5F57), size: dotSize),
          SizedBox(width: dotSize * 0.5),
          _Dot(color: const Color(0xFFFEBC2E), size: dotSize),
          SizedBox(width: dotSize * 0.5),
          _Dot(color: const Color(0xFF28C840), size: dotSize),
          SizedBox(width: dotSize),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: pad.left * 0.6, vertical: pad.top * 0.2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              language,
              style: TextStyle(
                color: AppColors.gradientEnd,
                fontSize: fontSize - 1,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copy(context),
            icon: Icon(Icons.copy_rounded, size: AppResponsive.iconSize(context, base: 18)),
            color: Colors.white70,
            tooltip: 'Copy code',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
/// Very lightweight tokenizer that colors Dart keywords and strings.
  TextSpan _highlight(String source) {
    const baseStyle = TextStyle(
      fontFamily: 'monospace',
      color: Color(0xFFE6E1FF),
      height: 1.55,
      fontSize: 12.5,
    );

    final stringRe = RegExp("'[^']*'|\"[^\"]*\"");
    final stringSpans = <(int, int)>[];
    for (final m in stringRe.allMatches(source)) {
      stringSpans.add((m.start, m.end));
    }

    final spans = <TextSpan>[];
    var cursor = 0;

    for (var i = 0; i <= stringSpans.length; i++) {
      final sStart = i < stringSpans.length ? stringSpans[i].$1 : source.length;
      final sEnd = i < stringSpans.length ? stringSpans[i].$2 : source.length;

      if (sStart > cursor) {
        spans.addAll(_colorPlain(source.substring(cursor, sStart)));
      }
      if (i < stringSpans.length) {
        spans.add(TextSpan(
          text: source.substring(sStart, sEnd),
          style: const TextStyle(color: Color(0xFFC3E88D)),
        ));
        cursor = sEnd;
      }
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  List<TextSpan> _colorPlain(String text) {
    final keywordRe = RegExp(
      r'\b(import|void|return|final|const|if|else|for|new|this|extends|'
      r'implements|class|static|override|required|int|String|double|'
      r'bool|async|await)\b',
    );
    const keywordColor = Color(0xFFC792EA);
    final result = <TextSpan>[];
    var p = 0;
    for (final m in keywordRe.allMatches(text)) {
      if (m.start > p) result.add(TextSpan(text: text.substring(p, m.start)));
      result.add(TextSpan(
        text: m.group(0),
        style: const TextStyle(color: keywordColor),
      ));
      p = m.end;
    }
    if (p < text.length) result.add(TextSpan(text: text.substring(p)));
    return result;
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, this.size = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
