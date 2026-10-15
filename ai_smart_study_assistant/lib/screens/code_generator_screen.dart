import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import 'processing_screen.dart';

/// Screen where the user describes what they want and asks AI for code.
class CodeGeneratorScreen extends StatefulWidget {
  final String defaultPrompt;

  const CodeGeneratorScreen({super.key, this.defaultPrompt = ''});

  @override
  State<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends State<CodeGeneratorScreen> {
  late final TextEditingController _prompt =
      TextEditingController(text: widget.defaultPrompt);

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  void _generate() {
    if (_prompt.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe what code you need first.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          prompt: _prompt.text.trim(),
          forcedType: AIResultType.code,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final padding = AppResponsive.horizontalPadding(context);
    final radius = AppResponsive.responsiveRadius(context);
    
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left, 
                  padding.top * 0.5, 
                  padding.right, 
                  0
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: scheme.onSurface,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    padding.top * 0.5,
                    padding.right,
                    padding.bottom * 2
                  ),
                  children: [
                    Text(
                      '💻 AI Code Generator',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    AppResponsive.verticalSpace(context, factor: 0.015),
                    Text(
                      'Generate code in any language: Python, JavaScript, Flutter, '
                      'Java, React, and more. Just describe what you want to build.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    AppResponsive.verticalSpace(context, factor: 0.04),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.subtleGradient,
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: radius * 0.9,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _prompt,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Describe your code',
                          hintText: 'e.g. Create a Flutter login screen with validation',
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.code_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(radius),
                            borderSide: BorderSide.none,
                          ),
                          filled: false,
                          contentPadding: EdgeInsets.all(padding.left * 0.8),
                        ),
                      ),
                    ),
                    AppResponsive.verticalSpace(context, factor: 0.02),
                    Container(
                      padding: EdgeInsets.all(padding.left * 0.6),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(radius * 0.8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1)
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: padding.left * 0.3),
                          Expanded(
                            child: Text(
                              'The AI returns working code, an explanation, and '
                              'the widgets used.',
                              style: TextStyle(
                                fontSize: AppResponsive.responsiveFontSize(
                                  context, min: 11, max: 13
                                ),
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppResponsive.verticalSpace(context, factor: 0.04),
                    GradientButton(
                      label: '⚡ Generate Code',
                      icon: Icons.auto_awesome,
                      onPressed: _generate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
