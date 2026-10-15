import 'chat_completions_service.dart';

/// Real Generative-AI provider backed by OpenAI's Chat Completions API
/// (ChatGPT — `gpt-4o-mini` by default).
///
/// This is a thin subclass of [ChatCompletionsService]; all request handling,
/// JSON parsing and offline fallback are inherited.
///
/// ## Credentials
///   - You need a single **OpenAI API key** (paid credits required to make API
///     calls beyond the trial).
///   - Sign up at <https://platform.openai.com>, create a key at
///     <https://platform.openai.com/api-keys>, then set `OPENAI_API_KEY`.
///
/// For a free alternative see [FreeGroqService] (no card, no credit).
class LiveOpenAIService extends ChatCompletionsService {
  LiveOpenAIService() : super(
        endpoint: 'https://api.openai.com/v1/chat/completions',
        model: 'gpt-4o-mini',
        apiKeyKeyName: 'OPENAI_API_KEY',
        name: 'OpenAI GPT',
      );
}
