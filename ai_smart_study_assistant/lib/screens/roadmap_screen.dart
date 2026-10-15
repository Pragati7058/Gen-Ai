import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/roadmap.dart';
import '../widgets/gradient_background.dart';
import '../widgets/section_title.dart';
import 'home_screen.dart';

/// Renders a generated learning roadmap as an interactive vertical timeline.
class RoadmapScreen extends StatefulWidget {
  final Roadmap roadmap;
  final String goal;

  const RoadmapScreen({super.key, required this.roadmap, required this.goal});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: AppResponsive.contentPadding(context, bottom: 120),
                  children: [
                    _hero(context),
                    const SizedBox(height: 24),
                    const SectionTitle(
                        title: 'Your Learning Roadmap', icon: '🛣️'),
                    ...List.generate(
                        widget.roadmap.steps.length, (i) => _step(context, i)),
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
          const Text('🗺️'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Roadmap',
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
            '🎯 Your Goal',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            widget.goal,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _heroStat(context, '${widget.roadmap.steps.length}', 'Steps'),
              const SizedBox(width: 24),
              _heroStat(
                  context,
                  '~${widget.roadmap.totalDurationWeeks} wks',
                  'Est. time'),
              const SizedBox(width: 24),
              _heroStat(context, '${_completed.length}', 'Done'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
Widget _step(BuildContext context, int index) {
    final step = widget.roadmap.steps[index];
    final isDone = _completed.contains(step.step);
    final scheme = Theme.of(context).colorScheme;
    final isLast = index == widget.roadmap.steps.length - 1;
    final difficultyColor = AppColors.difficultyColor(step.difficulty);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDone ? AppColors.brandGradient : null,
                  color: isDone ? null : scheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isDone ? Colors.transparent : AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : Text(
                          '${step.step}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? AppColors.primary.withValues(alpha:0.5)
                        : scheme.outlineVariant.withValues(alpha:0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.topic,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: scheme.onSurface),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          step.difficulty,
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          color: scheme.onSurfaceVariant, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        step.duration,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          if (isDone) {
                            _completed.remove(step.step);
                          } else {
                            _completed.add(step.step);
                          }
                        }),
                        icon: Icon(
                          isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 18,
                          color: isDone
                              ? AppColors.success
                              : scheme.onSurfaceVariant,
                        ),
                        label: Text(isDone ? 'Completed' : 'Mark done'),
                        style: TextButton.styleFrom(
                          foregroundColor: isDone
                              ? AppColors.success
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
