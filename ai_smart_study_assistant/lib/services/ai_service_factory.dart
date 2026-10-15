import 'ai_service.dart';
import 'free_groq_service.dart';
import 'live_openai_service.dart';
import 'mock_ai_service.dart';
import '../core/constants/api_config.dart';

/// Decides which Gen-AI provider the app runs with.
///
/// Priority (all free to try, none require changes to the UI):
///   1. **Groq** (FREE, no card)  — when `GROQ_API_KEY` is set
///   2. **OpenAI GPT**            — when `OPENAI_API_KEY` is set
///   3. **Mock engine** (offline) — otherwise (always works for demos)
///
/// The local key is read from [ApiConfig]. A dart-define is supported only as
/// a fallback when the config value is empty.
///
/// The UI depends only on [AIService], so swapping providers never changes a
/// widget.
class AIServiceFactory {
  AIServiceFactory._();

  static AIService createDefault() {
    // The config file is the app's primary provider configuration.
    if (ApiConfig.resolvedGroqKey != null) return FreeGroqService();
    if (ApiConfig.resolvedOpenaiKey != null) return LiveOpenAIService();

    // Optional fallback for CI/CD and local launches without config changes.
    final dartDefineGroq = const String.fromEnvironment('GROQ_API_KEY');
    final dartDefineOpenai = const String.fromEnvironment('OPENAI_API_KEY');
    if (dartDefineGroq.isNotEmpty) return FreeGroqService();
    if (dartDefineOpenai.isNotEmpty) return LiveOpenAIService();

    // Fallback: offline mock engine.
    return MockAIService();
  }
}
