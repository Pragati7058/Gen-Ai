import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import 'processing_screen.dart';

/// Screen where the user picks a technology + difficulty and asks AI for a
/// project idea.
class ProjectGeneratorScreen extends StatefulWidget {
  const ProjectGeneratorScreen({super.key});

  @override
  State<ProjectGeneratorScreen> createState() =>
      _ProjectGeneratorScreenState();
}

class _ProjectGeneratorScreenState extends State<ProjectGeneratorScreen> {
  static const _techs = ['Flutter', 'React', 'Python', 'Java', 'AI'];
  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  String _tech = 'Flutter';
  String _difficulty = 'Beginner';

  void _generate() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          prompt: 'Generate a $_difficulty $_tech project idea',
          forcedType: AIResultType.project,
          projectTechnology: _tech,
          projectDifficulty: _difficulty,
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
              Padding(
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
              ),
              Expanded(
                child: ListView(
                  padding: AppResponsive.contentPadding(context, bottom: 40),
                  children: [
                    Text(
                      '💡 AI Project Idea Generator',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick a technology and difficulty to get a tailored '
                      'project idea.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    _choiceSection(
                      context,
                      title: 'Technology',
                      icon: Icons.devices_rounded,
                      options: _techs,
                      selected: _tech,
                      onSelect: (v) => setState(() => _tech = v),
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
                      label: '✨ Generate Project Idea',
                      icon: Icons.lightbulb_rounded,
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
                            color:
                                (accent ?? AppColors.primary).withValues(alpha:0.4),
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
