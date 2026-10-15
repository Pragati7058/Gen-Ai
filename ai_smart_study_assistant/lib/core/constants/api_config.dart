// ╔══════════════════════════════════════════════════════════════════╗
// ║              🔑 API KEY CONFIGURATION                         ║
// ║                                                                ║
// ║  Paste your API key below, then restart the app.               ║
// ║                                                                ║
// ║  Priority:                                                     ║
// ║    1. GROQ_API_KEY  (FREE — no credit card needed)             ║
// ║    2. OPENAI_API_KEY (paid credits required)                   ║
// ║    3. Mock engine (offline demo — always works)                ║
// ║                                                                ║
// ║  Get a FREE Groq key: https://console.groq.com/keys            ║
// ║  Get an OpenAI key:   https://platform.openai.com/api-keys     ║
// ╚══════════════════════════════════════════════════════════════════╝

library;

class ApiConfig {
  ApiConfig._();

  /// Set this value once and restart the app. All AI modules use it.
  static const String groqApiKey = 'add here';

  /// OpenAI API key (paid credits required beyond trial).
  /// Sign up at https://platform.openai.com and create a key at
  /// https://platform.openai.com/api-keys
  static const String openaiApiKey = '';

  /// Returns the Groq key if set, null otherwise.
  static String? get resolvedGroqKey =>
      groqApiKey.trim().isEmpty ? null : groqApiKey.trim();

  /// Returns the OpenAI key if set, null otherwise.
  static String? get resolvedOpenaiKey =>
      openaiApiKey.trim().isEmpty ? null : openaiApiKey.trim();
}
