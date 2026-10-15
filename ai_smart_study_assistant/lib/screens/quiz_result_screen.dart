import '../core/responsive_utils.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/quiz.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/info_chip.dart';
import 'home_screen.dart';
import 'quiz_generator_screen.dart';

/// Interactive quiz-taking experience with instant feedback, AI explanations,
/// live scoring and a completion summary.
class QuizResultScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizResultScreen({super.key, required this.quiz});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  int _index = 0;
  final List<QuizAnswerResult> _attempts = [];
  int _score = 0;
  bool _finished = false;

  QuizQuestion get _question => widget.quiz.questions[_index];

  void _select(String label) {
    if (_isAnswered(_index)) return;
    final q = _question;
    final isCorrect = label == q.correctLabel;
    setState(() {
      if (isCorrect) _score++;
      _attempts.add(QuizAnswerResult(
        question: q,
        selectedLabel: label,
        isCorrect: isCorrect,
      ));
    });
  }

  bool _isAnswered(int index) {
    return _attempts.any((a) => a.question == widget.quiz.questions[index]);
  }

  void _next() {
    if (_index + 1 < widget.quiz.questions.length) {
      setState(() => _index++);
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _attempts.clear();
      _score = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: _finished ? _completion(context) : _quizView(context),
        ),
      ),
    );
  }
Widget _quizView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answered = _isAnswered(_index);
    final attempt = answered
        ? _attempts.firstWhere((a) => a.question == _question)
        : null;

    return Column(
      children: [
        _header(context),
        Padding(
          padding: AppResponsive.horizontalPadding(context),
          child: Row(
            children: [
              InfoChip(label: '${_index + 1}/${widget.quiz.total}'),
              SizedBox(width: AppResponsive.gapWidth(context, base: 8)),
              InfoChip(label: 'Score: $_score', color: AppColors.primary),
              const Spacer(),
              Text(
                widget.quiz.difficulty,
                style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        SizedBox(height: AppResponsive.gapWidth(context, base: 10)),
        Padding(
          padding: AppResponsive.horizontalPadding(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / widget.quiz.total,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppResponsive.contentPadding(context, top: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: AppResponsive.containerPadding(context),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(
                        AppResponsive.responsiveRadius(context)),
                  ),
                  child: Text(
                    'Q${_index + 1}. ${_question.question}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: scheme.onSurface),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_question.options.length, (i) {
                  final option = _question.options[i];
                  return _optionCard(context, option, attempt);
                }),
                if (answered && attempt != null) ...[
                  const SizedBox(height: 16),
                  _explanationCard(context, attempt),
                ],
              ],
            ),
          ),
        ),
        if (answered)
          Container(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              label: _index + 1 < widget.quiz.total
                  ? 'Next Question'
                  : 'See Results',
              icon: Icons.arrow_forward_rounded,
              onPressed: _next,
            ),
          ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: scheme.onSurface,
          ),
          const Text('🧠'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Quiz',
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
Widget _optionCard(BuildContext context, QuizOption option, QuizAnswerResult? attempt) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = attempt?.selectedLabel == option.label;
    final isCorrectAnswer = option.label == _question.correctLabel;

    Color? borderColor;
    IconData? trailing;
    if (attempt != null) {
      if (isCorrectAnswer) {
        borderColor = AppColors.success;
        trailing = Icons.check_circle_rounded;
      } else if (isSelected) {
        borderColor = AppColors.danger;
        trailing = Icons.cancel_rounded;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: borderColor != null
            ? borderColor.withValues(alpha:0.08)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: attempt == null ? () => _select(option.label) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor ?? Colors.transparent,
                width: 1.6,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderColor ??
                        (isSelected ? scheme.primary : scheme.surface),
                    border: Border.all(color: borderColor ?? Colors.white12),
                  ),
                  child: Center(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: borderColor ?? scheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (trailing != null)
                  Icon(trailing,
                      color: borderColor ?? scheme.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _explanationCard(BuildContext context, QuizAnswerResult attempt) {
    final scheme = Theme.of(context).colorScheme;
    final correct = attempt.isCorrect;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: correct
            ? LinearGradient(colors: [
                AppColors.success.withValues(alpha:0.15),
                scheme.surface,
              ])
            : LinearGradient(colors: [
                AppColors.danger.withValues(alpha:0.15),
                scheme.surface,
              ]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (correct ? AppColors.success : AppColors.danger)
              .withValues(alpha:0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle_rounded : Icons.error_rounded,
                color: correct ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 10),
              Text(
                correct ? 'Correct Answer' : 'Not quite',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Correct answer: ${attempt.question.correctOption.label}. '
                    '${attempt.question.correctOption.text}',
                    style: const TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '✨ AI Explanation',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            attempt.question.explanation,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
Widget _completion(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = widget.quiz.total;
    final percent = total == 0 ? 0.0 : (_score / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            'Quiz Completed',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Topic: ${widget.quiz.topic}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha:0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_score / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${(percent * 100).round()}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            percent >= 0.7
                ? 'Amazing! You really know ${widget.quiz.topic} 👏'
                : 'Good try! Keep practicing and you\'ll master it 💪',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            onPressed: _restart,
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'New Quiz',
            icon: Icons.add_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) =>
                        QuizGeneratorScreen(defaultTopic: widget.quiz.topic)),
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

