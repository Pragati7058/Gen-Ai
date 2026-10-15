import '../models/code_result.dart';
import '../models/learning_content.dart';
import '../models/project_idea.dart';
import '../models/quiz.dart';
import '../models/roadmap.dart';

/// Abstracts every Generative-AI operation the UI needs.
///
/// The full Flutter UI depends only on this interface. Different providers
/// (Mock / OpenAI / Gemini / Claude) are plain implementations of this
/// interface and can be swapped without touching any widget code.
abstract class AIService {
  /// Human readable name of the backing provider (shown in the UI).
  String get providerName;

  /// Whether this implementation returns sample (non-network) data.
  bool get isMock;
  
  /// Answers a free-form conversational prompt.
  Future<String> generateChatResponse(String prompt);

  /// Generates a structured explanation / learning experience for [prompt].
  Future<LearningContent> generateLearningContent(String prompt);

  /// Generates [count] multiple-choice questions about [topic].
  Future<Quiz> generateQuiz({
    required String topic,
    required int count,
    required String difficulty,
  });

  /// Generates a step-by-step learning roadmap for [goal].
  Future<Roadmap> generateRoadmap(String goal);

  /// Generates code, an explanation and used widgets for [prompt].
  Future<CodeResult> generateCode(String prompt);

  /// Generates a project idea for the given [technology] and [difficulty].
  Future<ProjectIdea> generateProjectIdea({
    required String technology,
    required String difficulty,
  });
}
