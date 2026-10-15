import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/code_result.dart';
import '../widgets/code_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/section_title.dart';
import 'home_screen.dart';

/// Displays generated code with explanation, widgets used, and AI actions
/// (Explain / Find Error / Improve).
class CodeScreen extends StatelessWidget {
  final CodeResult result;

  const CodeScreen({super.key, required this.result});

  void _analyze(BuildContext context, _CodeAction action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AnalysisSheet(result: result, action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.horizontalPadding(context);
    
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    padding.top * 0.5,
                    padding.right,
                    padding.bottom * 4
                  ),
                  children: [
                    const SectionTitle(title: 'Generated Code', icon: '💻'),
                    CodeCard(
                      title: result.title,
                      language: result.language,
                      code: result.code,
                      widgetsUsed: result.widgetsUsed,
                    ),
                    AppResponsive.verticalSpace(context, factor: 0.03),
                    _explanationCard(context),
                    AppResponsive.verticalSpace(context, factor: 0.03),
                    _actionRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        ),
        icon: const Icon(Icons.home_rounded),
        label: const Text('Home'),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: AppResponsive.headerPadding(context),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: scheme.onSurface,
          ),
          const Text('🛠️'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Code Assistant',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _explanationCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = AppResponsive.responsiveRadius(context);
    final padding = AppResponsive.horizontalPadding(context);
    
    return Container(
      padding: EdgeInsets.all(padding.left * 0.8),
      decoration: BoxDecoration(
        gradient: AppColors.subtleGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: radius * 0.8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Code Explanation', icon: '💡'),
          AppResponsive.verticalSpace(context, factor: 0.015),
          Text(
            result.explanation,
            style: TextStyle(
              color: scheme.onSurface, 
              height: 1.5,
              fontSize: AppResponsive.responsiveFontSize(
                context, min: 14, max: 16
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
          AppResponsive.verticalSpace(context, factor: 0.025),
          const SectionTitle(title: 'Important Widgets Used', icon: '🧩'),
          AppResponsive.verticalSpace(context, factor: 0.01),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.widgetsUsed
                .map((w) => Chip(
                      label: Text(w),
                      backgroundColor: AppColors.primary.withValues(alpha:0.1),
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: scheme.primary,
                        fontSize: AppResponsive.responsiveFontSize(
                          context, min: 12, max: 14
                        )
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = AppResponsive.responsiveRadius(context);
    final padding = AppResponsive.horizontalPadding(context);
    
    return Container(
      padding: EdgeInsets.all(padding.left * 0.8),
      decoration: BoxDecoration(
        gradient: AppColors.subtleGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: radius * 0.9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let AI help you with this code',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: scheme.onSurface),
          ),
          AppResponsive.verticalSpace(context, factor: 0.025),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionChip(context, '✨ Explain Code', Icons.menu_book_rounded,
                  _CodeAction.explain),
              _actionChip(context, '🐛 Find Error', Icons.bug_report_rounded,
                  _CodeAction.error),
              _actionChip(
                  context,
                  '🚀 Improve Code',
                  Icons.rocket_launch_rounded,
                  _CodeAction.improve),
            ],
          ),
        ],
      ),
    );
  }
Widget _actionChip(
      BuildContext context, String label, IconData icon, _CodeAction action) {
    final padding = AppResponsive.horizontalPadding(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _analyze(context, action),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding.left * 0.8, 
              vertical: padding.left * 0.5
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                SizedBox(width: padding.left * 0.3),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppResponsive.responsiveFontSize(
                      context, min: 12, max: 14
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _CodeAction { explain, error, improve }
/// Bottom sheet that simulates an AI code review with a short "thinking" state.
class _AnalysisSheet extends StatefulWidget {
  final CodeResult result;
  final _CodeAction action;

  const _AnalysisSheet({required this.result, required this.action});

  @override
  State<_AnalysisSheet> createState() => _AnalysisSheetState();
}

class _AnalysisSheetState extends State<_AnalysisSheet> {
  bool _thinking = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _thinking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: AppResponsive.contentPadding(context, top: 16, bottom: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _thinking ? _thinkingView(context) : _resultView(context),
          ],
        ),
      ),
    );
  }

  Widget _thinkingView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 20),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text(
          'AI is analyzing your code…',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _resultView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final padding = AppResponsive.horizontalPadding(context);
    final (String title, IconData icon, String body) = switch (widget.action) {
      _CodeAction.explain => (
          'Code Explanation',
          Icons.menu_book_rounded,
          widget.result.explanation,
        ),
      _CodeAction.error => (
          'Code Analysis',
          Icons.bug_report_rounded,
          '📊 Code Review Results for "${widget.result.title}":\n\n'
          '✅ Basic structure and syntax appear correct\n'
          '⚠️ Note: Always test generated code thoroughly\n'
          '🔍 Consider adding error handling and validation\n'
          '📱 Test on actual devices before deployment\n'
          '🎯 Ensure code matches your specific requirements',
        ),
      _CodeAction.improve => (
          'Enhancement Suggestions',
          Icons.rocket_launch_rounded,
          '💡 Ideas to enhance "${widget.result.title}":\n\n'
          '📦 Extract reusable components\n'
          '✨ Add comprehensive input validation\n'
          '🎨 Apply consistent styling with theme\n'
          '🧪 Include unit tests for critical functions\n'
          '📚 Add inline documentation\n'
          '♿ Consider accessibility improvements\n'
          '🔧 Optimize performance for large datasets',
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            SizedBox(width: padding.left * 0.4),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        AppResponsive.verticalSpace(context, factor: 0.02),
        Container(
          padding: EdgeInsets.all(padding.left * 0.6),
          decoration: BoxDecoration(
            gradient: AppColors.subtleGradient,
            borderRadius: BorderRadius.circular(AppResponsive.responsiveRadius(context) * 0.8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Text(
            body,
            style: TextStyle(
              color: scheme.onSurface, 
              height: 1.6,
              fontSize: AppResponsive.responsiveFontSize(context, min: 14, max: 16),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
