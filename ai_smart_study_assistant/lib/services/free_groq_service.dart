import 'chat_completions_service.dart';

/// # Totally free Generative-AI provider using Groq's free tier.
///
/// Groq hosts open-source models (Llama, GPT-OSS) and gives **free** API
/// access with NO credit card and NO paid credit — just a free API key from
/// <https://console.groq.com/keys>.
///
/// It speaks the OpenAI-compatible `/chat/completions` API, so it reuses the
/// exact same request/JSON-parsing code as the OpenAI provider via
/// [ChatCompletionsService].
///
/// ## Credentials
///   - Sign up free at <https://console.groq.com>
///   - Create a key at <https://console.groq.com/keys>
///   - Set it as the `GROQ_API_KEY` environment variable.
///
/// Set `GROQ_API_KEY` and the factory will automatically use this free
/// provider. The free tier has generous per-minute limits (typically 30 RPM
/// and 8k–70k tokens/min depending on model) — plenty for a workshop demo.
class FreeGroqService extends ChatCompletionsService {
  FreeGroqService() : super(
        endpoint: 'https://api.groq.com/openai/v1/chat/completions',
        model: 'openai/gpt-oss-20b',
        apiKeyKeyName: 'GROQ_API_KEY',
        name: 'Groq GPT-OSS (Free)',
      );
}
