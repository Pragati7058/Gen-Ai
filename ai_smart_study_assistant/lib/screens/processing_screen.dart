import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/responsive_utils.dart';
import '../core/theme/app_theme.dart';
import '../models/code_result.dart';
import '../models/learning_content.dart';
import '../models/project_idea.dart';
import '../models/quiz.dart';
import '../models/roadmap.dart';
import '../services/ai_service.dart';
import '../widgets/animated_ai_orb.dart';
import '../widgets/gradient_background.dart';
import 'code_screen.dart';
import 'learning_screen.dart';
import 'project_screen.dart';
import 'quiz_result_screen.dart';
import 'roadmap_screen.dart';

/// Identifies what kind of content to generate.
enum AIResultType { learning, quiz, roadmap, code, project }

/// Guesses the desired content type from a natural-language prompt.
AIResultType inferResultType(String prompt) {
  final p = prompt.toLowerCase();
  if (p.contains('quiz')) return AIResultType.quiz;
  if (p.contains('roadmap') ||
      p.contains('learning path') ||
      p.contains('to become') ||
      p.contains('developer')) {
    return AIResultType.roadmap;
  }
  if (p.contains('code') ||
      p.contains('widget') ||
      p.contains('screen') ||
      p.contains('button') ||
      p.contains('login')) {
    return AIResultType.code;
  }
  if (p.contains('project') ||
      p.contains('idea') ||
      p.contains('app idea') ||
      p.contains('build app')) {
    return AIResultType.project;
  }
  return AIResultType.learning;
}

/// The animated "Generative AI is thinking" experience.
class ProcessingScreen extends StatefulWidget {
  final String prompt;
  final AIResultType? forcedType;
  final int quizCount;
  final String quizDifficulty;
  final String projectTechnology;
  final String projectDifficulty;

  const ProcessingScreen({
    super.key,
    required this.prompt,
    this.forcedType,
    this.quizCount = 5,
    this.quizDifficulty = 'Intermediate',
this.projectTechnology = 'Flutter',
    this.projectDifficulty = 'Beginner',
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}
class _ProcessingScreenState extends State<ProcessingScreen> {
  late final AIResultType _type =
      widget.forcedType ?? inferResultType(widget.prompt);

  late final List<({String icon, String label})> _steps = _stepsFor(_type);

  int _currentStep = 0;
  bool _done = false;
  Object? _error;

  LearningContent? _learning;
  Quiz? _quiz;
  Roadmap? _roadmap;
  CodeResult? _code;
  ProjectIdea? _project;

  List<({String icon, String label})> _stepsFor(AIResultType type) {
    switch (type) {
      case AIResultType.quiz:
        return const [
          (icon: '🧠', label: 'Analyzing your topic'),
          (icon: '📋', label: 'Crafting questions'),
          (icon: '✅', label: 'Verifying answers'),
          (icon: '🎉', label: 'Preparing your quiz'),
        ];
      case AIResultType.roadmap:
        return const [
          (icon: '🧠', label: 'Understanding your goal'),
          (icon: '🗺️', label: 'Mapping skills to learn'),
          (icon: '🧱', label: 'Building the path'),
          (icon: '🚀', label: 'Preparing your roadmap'),
        ];
      case AIResultType.code:
        return const [
          (icon: '🧠', label: 'Understanding your request'),
          (icon: '💻', label: 'Writing high-quality code'),
          (icon: '🧪', label: 'Reviewing the solution'),
          (icon: '✨', label: 'Polishing the output'),
        ];
      case AIResultType.project:
        return const [
          (icon: '🧠', label: 'Analyzing the domain'),
          (icon: '💡', label: 'Brainstorming ideas'),
          (icon: '🛠️', label: 'Selecting the best fit'),
          (icon: '✨', label: 'Finalizing your project'),
        ];
      case AIResultType.learning:
        return const [
          (icon: '🧠', label: 'Understanding your request'),
          (icon: '📚', label: 'Searching concepts'),
          (icon: '✨', label: 'Generating personalized content'),
          (icon: '🎯', label: 'Creating your learning experience'),
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final service = context.read<AIService>();
    final future = _generate(service);

    for (var i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;
      setState(() => _currentStep = i + 1);
    }

    try {
      final results = await future;
      if (!mounted) return;
      _learning = results.$1;
      _quiz = results.$2;
      _roadmap = results.$3;
      _code = results.$4;
      _project = results.$5;
      setState(() => _done = true);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) _navigate();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<(LearningContent?, Quiz?, Roadmap?, CodeResult?, ProjectIdea?)>
      _generate(AIService service) async {
    switch (_type) {
      case AIResultType.learning:
        final r = await service.generateLearningContent(widget.prompt);
        return (r, null, null, null, null);
      case AIResultType.quiz:
        final r = await service.generateQuiz(
          topic: widget.prompt,
          count: widget.quizCount,
          difficulty: widget.quizDifficulty,
        );
        return (null, r, null, null, null);
      case AIResultType.roadmap:
        final r = await service.generateRoadmap(widget.prompt);
        return (null, null, r, null, null);
      case AIResultType.code:
        final r = await service.generateCode(widget.prompt);
        return (null, null, null, r, null);
      case AIResultType.project:
        final r = await service.generateProjectIdea(
          technology: widget.projectTechnology,
          difficulty: widget.projectDifficulty,
        );
        return (null, null, null, null, r);
    }
  }

  void _navigate() {
    Widget route = switch (_type) {
      AIResultType.learning => LearningScreen(content: _learning!),
      AIResultType.quiz => QuizResultScreen(quiz: _quiz!),
      AIResultType.roadmap =>
        RoadmapScreen(roadmap: _roadmap!, goal: widget.prompt),
      AIResultType.code => CodeScreen(result: _code!),
      AIResultType.project => ProjectScreen(idea: _project!),
    };
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => route,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: AppResponsive.horizontalPadding(context),
            child: Column(
              children: [
                const Spacer(),
                const AnimatedAIOrb(size: 110),
                const SizedBox(height: 32),
                Text(
                  _completed() ? 'Done!' : 'AI is working…',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Solving "${_shortPrompt()}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 30),
                ...List.generate(_steps.length, (i) => _stepRow(context, i)),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: LinearProgressIndicator(
                    value: _completed() ? 1 : (_currentStep / _steps.length),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _completed() => _done || _error != null;

  String _shortPrompt() {
    final p = widget.prompt.trim();
    if (p.length <= 42) return p;
    return '${p.substring(0, 42)}…';
  }

  Widget _stepRow(BuildContext context, int index) {
    final done = index < _currentStep || _done || _error != null;
    final active = index == _currentStep && !_done && _error == null;
    final scheme = Theme.of(context).colorScheme;
    final step = _steps[index];
    final color = done
        ? AppColors.success
        : active
            ? scheme.primary
            : scheme.outlineVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? scheme.primary.withValues(alpha: 0.5)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.15),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: done ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, color: AppColors.success)
                  : active
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: scheme.primary,
                          ),
                        )
                      : Text(step.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              step.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (done)
            Text(
              '✓',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
