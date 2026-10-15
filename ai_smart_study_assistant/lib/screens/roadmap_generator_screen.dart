import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import 'processing_screen.dart';

/// Screen where the user types a learning goal and asks AI for a roadmap.
class RoadmapGeneratorScreen extends StatefulWidget {
  final String defaultGoal;

  const RoadmapGeneratorScreen({super.key, this.defaultGoal = ''});

  @override
  State<RoadmapGeneratorScreen> createState() => _RoadmapGeneratorScreenState();
}

class _RoadmapGeneratorScreenState extends State<RoadmapGeneratorScreen> {
  late final TextEditingController _goal =
      TextEditingController(text: widget.defaultGoal);

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  void _generate() {
    if (_goal.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tell me your learning goal first.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          prompt: _goal.text.trim(),
          forcedType: AIResultType.roadmap,
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
                      '🛣️ AI Learning Roadmap',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Share your goal and let Generative AI design a '
                      'step-by-step path to get there.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _goal,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Learning goal',
                        hintText: "e.g. I want to become a Flutter Developer",
                        alignLabelWithHint: true,
                        prefixIcon:
                            Icon(Icons.route_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pro tip: Be specific about your goal for the '
                            'best roadmap.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: '🔮 Generate Roadmap',
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
