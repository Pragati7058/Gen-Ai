import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';
import '../models/code_result.dart';
import '../models/learning_content.dart';
import '../models/project_idea.dart';
import '../models/quiz.dart';
import '../models/roadmap.dart';
import 'ai_service.dart';
import 'mock_ai_service.dart';
import 'structured_result_parser.dart';

/// Reusable base for any provider that speaks the OpenAI-compatible
/// `POST /chat/completions` JSON API (OpenAI, Groq, OpenRouter, ...).
///
/// Subclasses only provide the endpoint, model name, display name and API key;
/// the request/response handling, JSON parsing into the strong-typed models
/// and the offline fallback are all shared here.
abstract class ChatCompletionsService implements AIService {
  ChatCompletionsService({
    required String endpoint,
    required String model,
    required String apiKeyKeyName,
    required String name,
    http.Client? client,
    MockAIService? localParser,
    StructuredResultParser? parser,
  })  : _endpoint = endpoint,
        _model = model,
        _apiKeyKeyName = apiKeyKeyName,
        _name = name,
        _client = client ?? http.Client(),
        _local = localParser ?? MockAIService(),
        _parser = parser ?? const StructuredResultParser();

  final String _endpoint;
  final String _model;
  final String _apiKeyKeyName;
  final String _name;

  final http.Client _client;
  final MockAIService _local;
  final StructuredResultParser _parser;

  @override
  String get providerName => _name;

  @override
  bool get isMock => false;

  Future<String> _chat(
    String system,
    String userPrompt, {
    bool jsonResponse = true,
  }) async {
    // ApiConfig is primary; dart-define is only a fallback.
    var key = _apiKeyKeyName == 'GROQ_API_KEY'
        ? ApiConfig.resolvedGroqKey ?? ''
        : ApiConfig.resolvedOpenaiKey ?? '';
    if (key.isEmpty) {
      key = String.fromEnvironment(_apiKeyKeyName);
    }
    if (key.isEmpty) {
      throw StateError(
        '$_name API key is not set. Add it to '
        'lib/core/constants/api_config.dart and restart the app.',
      );
    }

    final payload = <String, dynamic>{
      'model': _model,
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.7,
    };
    if (jsonResponse) {
      payload['response_format'] = {'type': 'json_object'};
    }

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        '$_name error ${response.statusCode}: ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['choices'] as List).first['message']['content'] as String;
  }
@override
  Future<LearningContent> generateLearningContent(String prompt) async {
    final fallback = await _local.generateLearningContent(prompt);
    try {
      final raw = await _chat(
        'You are a friendly study assistant. Return ONLY valid JSON with '
            'this schema: {"topic":string,"overview":string,'
            '"flow":[{label,icon}],"examples":[{title,subtitle,icon,color}],'
            '"sections":[{title,icon,content,'
            'subSections:[{title,icon,content}]}]}. '
            'Write clear, structured content for a student.',
        prompt,
      );
      return _parser.learningContent(jsonDecode(raw), fallback);
    } catch (_) {
      return fallback;
    }
  }
  
  @override
  Future<String> generateChatResponse(String prompt) {
    return _chat(
      'You are a friendly, concise study assistant. Answer the student\'s '
          'question clearly with useful examples when appropriate. Use plain '
          'text and Markdown; do not return JSON.',
      prompt,
      jsonResponse: false,
    );
  }

  @override
  Future<Quiz> generateQuiz({
    required String topic,
    required int count,
    required String difficulty,
  }) async {
    final fallback = await _local.generateQuiz(
      topic: topic,
      count: count,
      difficulty: difficulty,
    );
    try {
      final raw = await _chat(
        'You are a quiz generator. Return ONLY valid JSON with this schema: '
            '{"topic":string,"questions":[{question,"options":[{text}],'
            '"correctLabel":"A"|"B"|"C"|"D",explanation}]}. '
            'Provide exactly $count questions with 4 options each, ordered '
            'A,B,C,D.',
        'Create a $difficulty multiple-choice quiz on: $topic',
      );
      return _parser.quiz(jsonDecode(raw), fallback, difficulty);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<Roadmap> generateRoadmap(String goal) async {
    final fallback = await _local.generateRoadmap(goal);
    try {
      final raw = await _chat(
        'You are a career mentor. Return ONLY valid JSON with this schema: '
            '{"goal":string,"steps":[{topic,description,duration,'
            'difficulty}]}. Create 6-8 sequential learning steps.',
        'Create a step-by-step learning roadmap to: $goal',
      );
      return _parser.roadmap(jsonDecode(raw), fallback, goal);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<CodeResult> generateCode(String prompt) async {
    final fallback = await _local.generateCode(prompt);
    try {
      final raw = await _chat(
        'You are an expert developer. Return ONLY valid JSON with this '
            'schema: {"title":string,"language":string,"code":string,'
            '"explanation":string,"widgetsUsed":[string]}. Escape newlines '
            'properly inside the JSON string values. Detect the programming '
            'language requested by the user and generate code in that exact '
            'language. Never replace Python, JavaScript, Java, or another '
            'requested language with Dart or Flutter. Set language to the '
            'language name used by the code.',
        'Generate code for this request: $prompt',
      );
      final result = _parser.code(jsonDecode(raw), fallback);
      final requestedLanguage = _requestedLanguage(prompt);
      if (requestedLanguage != null &&
          !_languageMatches(result.language, requestedLanguage)) {
        return fallback;
      }
      return result;
    } catch (_) {
      return fallback;
    }
  }

  String? _requestedLanguage(String prompt) {
    final lower = prompt.toLowerCase();
    if (RegExp(r'\bpython\b|\bpy\b|django|flask').hasMatch(lower)) {
      return 'python';
    }
    if (RegExp(r'javascript|\bjs\b|node\.js|react').hasMatch(lower)) {
      return 'javascript';
    }
    if (RegExp(r'typescript|\bts\b').hasMatch(lower)) return 'typescript';
    if (RegExp(r'\bjava\b|spring boot').hasMatch(lower)) return 'java';
    if (RegExp(r'kotlin|android').hasMatch(lower)) return 'kotlin';
    if (RegExp(r'swift|ios').hasMatch(lower)) return 'swift';
    if (RegExp(r'c#|csharp|\.net').hasMatch(lower)) return 'csharp';
    if (RegExp(r'\bdart\b|flutter').hasMatch(lower)) return 'dart';
    return null;
  }

  bool _languageMatches(String actual, String requested) {
    final normalized = actual.toLowerCase().replaceAll('#', 'sharp');
    return normalized.contains(requested);
  }

  @override
  Future<ProjectIdea> generateProjectIdea({
    required String technology,
    required String difficulty,
  }) async {
    final fallback = await _local.generateProjectIdea(
      technology: technology,
      difficulty: difficulty,
    );
    try {
      final raw = await _chat(
        'You are a project-idea generator for students. Return ONLY valid '
            'JSON with this schema: {"name":string,"description":string,'
            '"features":[string],"technologies":[string],'
            '"difficulty":string,"estimatedTime":string}.',
        'Give me a $difficulty project idea using $technology with a clear '
            'description, 4-5 features, tech stack and estimated build time.',
      );
      return _parser.project(jsonDecode(raw), fallback, difficulty);
    } catch (_) {
      return fallback;
    }
  }
}
