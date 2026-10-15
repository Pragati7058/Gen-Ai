import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import 'processing_screen.dart';

/// Screen where the user configures a quiz (count + difficulty + topic)
/// and asks Generative AI to create it.
class QuizGeneratorScreen extends StatefulWidget {
  final String defaultTopic;

  const QuizGeneratorScreen({super.key, this.defaultTopic = ''});

  @override
  State<QuizGeneratorScreen> createState() => _QuizGeneratorScreenState();
}

class _QuizGeneratorScreenState extends State<QuizGeneratorScreen> {
  late final TextEditingController _topic =
      TextEditingController(text: widget.defaultTopic);
  int _count = 5;
  String _difficulty = 'Beginner';

  static const _counts = [5, 10, 15];
  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  void _generate() {
    if (_topic.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic first.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          prompt: _topic.text.trim(),
          forcedType: AIResultType.quiz,
          quizCount: _count,
          quizDifficulty: _difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: AppResponsive.contentPadding(context, bottom: 40),
                  children: [
                    Text(
                      'AI Quiz Generator',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick a topic, then let Generative AI create questions.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _topic,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        hintText: 'e.g. Python, Flutter, Generative AI',
                        prefixIcon: Icon(Icons.topic_outlined),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _choiceSection(
                      context,
                      title: 'Number of questions',
                      icon: Icons.format_list_numbered,
                      options: _counts.map((c) => '$c').toList(),
                      selected: '$_count',
                      onSelect: (v) => setState(() => _count = int.parse(v)),
                    ),
                    const SizedBox(height: 24),
                    _choiceSection(
                      context,
                      title: 'Difficulty',
                      icon: Icons.speed_rounded,
                      options: _difficulties,
                      selected: _difficulty,
                      onSelect: (v) => setState(() => _difficulty = v),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: '✨ Generate Quiz with AI',
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
        ],
      ),
    );
  }
Widget _choiceSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: scheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final isSelected = option == selected;
            final accent = _optionColor(option);
            return GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? (accent == null
                          ? AppColors.brandGradient
                          : LinearGradient(
                              colors: [accent, accent.withValues(alpha:0.7)]))
                      : null,
                  color: isSelected ? null : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white12,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accent?.withValues(alpha:0.4) ??
                                AppColors.primary.withValues(alpha:0.4),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color? _optionColor(String option) {
    switch (option.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.danger;
      default:
        return null;
    }
  }
}
