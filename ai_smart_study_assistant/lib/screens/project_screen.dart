import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/project_idea.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_title.dart';
import 'home_screen.dart';
import 'project_generator_screen.dart';
import 'quiz_generator_screen.dart';

/// Displays a generated project idea with features, tech, difficulty and
/// development time.
class ProjectScreen extends StatelessWidget {
  final ProjectIdea idea;

  const ProjectScreen({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: AppResponsive.contentPadding(context, bottom: 120),
                  children: [
                    _hero(context),
                    const SizedBox(height: 20),
                    _descriptionCard(context),
                    const SizedBox(height: 16),
                    _featuresCard(context),
                    const SizedBox(height: 16),
                    _techCard(context),
                    const SizedBox(height: 16),
                    _metaCard(context),
                    const SizedBox(height: 24),
                    _nextSteps(context),
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
          const Text('💡'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Project Idea',
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

  Widget _hero(BuildContext context) {
    final difficultyColor = AppColors.difficultyColor(idea.difficulty);
    final radius = AppResponsive.responsiveRadius(context);
    return Container(
      padding: AppResponsive.containerPadding(context),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚀 Project Idea',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            idea.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: difficultyColor.withValues(alpha:0.9),
                ),
                child: Text(
                  idea.difficulty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.schedule_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                idea.estimatedTime,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }

  Widget _descriptionCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Description', icon: '📝'),
          Text(
            idea.description,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
Widget _featuresCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Features', icon: '✨'),
          ...idea.features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(color: scheme.onSurface, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _techCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Technologies', icon: '🧰'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: idea.technologies
                .map((t) => Chip(
                      avatar: const Icon(Icons.terminal_rounded, size: 16),
                      label: Text(t),
                      backgroundColor: AppColors.primary.withValues(alpha:0.1),
                      side: BorderSide.none,
                      labelStyle: TextStyle(color: scheme.primary),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _metaCard(BuildContext context) {
    final difficultyColor = AppColors.difficultyColor(idea.difficulty);
    return _card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Project Details', icon: '📊'),
          _metaRow(context, 'Difficulty', idea.difficulty,
              color: difficultyColor),
          const Divider(height: 24),
          _metaRow(context, 'Est. Development Time', idea.estimatedTime),
          const Divider(height: 24),
          _metaRow(context, 'Tech Stack', idea.technologies.join(', ')),
        ],
      ),
    );
  }

  Widget _metaRow(BuildContext context, String label, String value,
      {Color? color}) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color ?? scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _nextSteps(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.subtleGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Next Steps', icon: '🚀'),
          GradientButton(
            label: 'Generate More Ideas',
            icon: Icons.lightbulb_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => ProjectGeneratorScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Generate a Quiz on this',
            icon: Icons.quiz_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizGeneratorScreen(defaultTopic: idea.name),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Back to Home',
            icon: Icons.home_rounded,
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
