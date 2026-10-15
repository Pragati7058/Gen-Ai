/// One option in a multiple choice question.
class QuizOption {
  final String label; // A, B, C, D
  final String text;

  const QuizOption({required this.label, required this.text});
}

/// A single multiple-choice question with the correct answer and an
/// AI-generated explanation.
class QuizQuestion {
  final String question;
  final List<QuizOption> options;
  final String correctLabel;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctLabel,
    required this.explanation,
  });

  QuizOption get correctOption =>
      options.firstWhere((o) => o.label == correctLabel);
}

/// A full generated quiz.
class Quiz {
  final String topic;
  final int total;
  final String difficulty;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.topic,
    required this.total,
    required this.difficulty,
    required this.questions,
  });
}

/// Tracks answers the user has given while taking a quiz.
class QuizAnswerResult {
  final QuizQuestion question;
  final String selectedLabel;
  final bool isCorrect;

  const QuizAnswerResult({
    required this.question,
    required this.selectedLabel,
    required this.isCorrect,
  });
}
