import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/code_result.dart';
import '../models/learning_content.dart';
import '../models/project_idea.dart';
import '../models/quiz.dart';
import '../models/roadmap.dart';
import 'ai_service.dart';

/// Offline Generative-AI implementation.
///
/// This class mimics the shape of a real LLM call but returns locally-built,
/// topic-aware content. Every generated value is parameterized by the user's
/// request (topic extraction + keyword profiles), so the content is never a
/// single hard-coded block. Swapping in a live API is a matter of writing a
/// new `AIService` implementation that calls `http`.
class MockAIService implements AIService {
  final Random _random = Random();
  final Duration _latency = const Duration(milliseconds: 900);

  @override
  String get providerName => 'Mock AI Engine';

  @override
  bool get isMock => true;
  
  @override
  Future<String> generateChatResponse(String prompt) async {
    await _think();
    final topic = _extractTopic(prompt);
    return 'I can help you learn $topic. Ask me for an explanation, an example, '
        'a study plan, or a practice question. Connect a Groq key with '
        '`ApiConfig.groqApiKey` to receive live AI answers.';
  }

  // ---------------------------------------------------------------------------
  // Topic & request inference
  // ---------------------------------------------------------------------------

  /// Pulls out the main noun-phrase (topic) from a free-text request.
  String _extractTopic(String input) {
    var text = input.trim().replaceAll(RegExp(r'[?!.]+$'), '');
    final stop = RegExp(
      r'^(please |can you |could you |help me |i want to |i want |i need to |'
      r'generate |create |make |build |give me |show me |teach me |explain |'
      r'tell me |what is |what are |about |on |a |an |the )+',
      caseSensitive: false,
    );
    text = text.replaceFirst(stop, '').trim();

    text = text
        .replaceAll(RegExp(r'^(quiz |code |roadmap |project )'), '')
        .trim();

    if (text.isEmpty) return 'this topic';
    final words = text.split(RegExp(r'\s+'));
    final meaningful = words
        .where((w) => !const {
              'of',
              'for',
              'with',
              'and',
              'in',
              'to',
              'a',
              'an'
            }.contains(w.toLowerCase()))
        .take(3)
        .join(' ');
    return meaningful.isEmpty ? 'this topic' : meaningful;
  }

  bool _mentions(String input, List<String> keywords) =>
      keywords.any((k) => input.toLowerCase().contains(k));
// ---------------------------------------------------------------------------
  // Learning content
  // ---------------------------------------------------------------------------

  @override
  Future<LearningContent> generateLearningContent(String prompt) async {
    await _think();
    return _buildLearningContent(_extractTopic(prompt), prompt);
  }

  LearningContent _buildLearningContent(String topic, String prompt) {
    final lower = prompt.toLowerCase();

    if (_mentions(lower, ['generative ai', 'genai', 'gen ai', 'generate ai'])) {
      return _generativeAiProfile('Generative AI');
    }
    if (_mentions(lower, ['flutter'])) return _flutterProfile(topic);
    if (_mentions(lower, ['machine learning', 'ml', 'ai model'])) {
      return _genericProfile(
        'Machine Learning',
        'the branch of AI that lets computers learn from data instead of being explicitly programmed.',
        const [
          'Supervised Learning',
          'Unsupervised Learning',
          'Reinforcement Learning',
        ],
        'predicting outcomes and finding patterns',
      );
    }
    if (_mentions(lower, ['python'])) {
      return _genericProfile(
        'Python',
        'a readable, high-level programming language loved for data science, automation and AI.',
        const [
          'Variables & Data Types',
          'Functions',
          'Libraries (NumPy, Pandas, Flask)',
        ],
        'writing clean scripts and building data pipelines',
      );
    }
    if (_mentions(lower, ['dart'])) {
      return _genericProfile(
        'Dart',
        'a modern, object-oriented language optimized for building fast multi-platform apps with Flutter.',
        const [
          'Dart Syntax',
          'OOP Concepts',
          'Asynchronous Programming',
        ],
        'building fast, type-safe applications',
      );
    }

    return _genericProfile(
      topic,
      '$topic is a powerful concept worth mastering — here is a focused, '
          'structured introduction built just for you.',
      _relativeConcepts(topic),
      'applying $topic to real problems',
    );
  }
LearningContent _generativeAiProfile(String topic) {
    return LearningContent(
      topic: topic,
      overview:
          'Generative AI is a branch of Artificial Intelligence that creates '
          'entirely new content — text, images, code, audio and video — by '
          'learning the underlying patterns of the data it was trained on. '
          'Instead of just storing or retrieving information, it *generates* '
          'something that never existed before.',
      flow: const [
        FlowStep(label: 'Data', icon: '🗂️'),
        FlowStep(label: 'AI Model', icon: '🤖'),
        FlowStep(label: 'Understanding Patterns', icon: '🧠'),
        FlowStep(label: 'Generated Content', icon: '✨'),
      ],
      examples: const [
        RealWorldExample(
            title: 'ChatGPT',
            subtitle: 'Conversational text generation & assistance',
            icon: '💬',
            color: Color(0xFF2E7D32)),
        RealWorldExample(
            title: 'Image Generation',
            subtitle: 'Creating art from a text description',
            icon: '🎨',
            color: Color(0xFF6A1B9A)),
        RealWorldExample(
            title: 'AI Voice',
            subtitle: 'Realistic speech synthesis & voice cloning',
            icon: '🎙️',
            color: Color(0xFFEF6C00)),
        RealWorldExample(
            title: 'AI Video',
            subtitle: 'Generating short videos from prompts',
            icon: '🎬',
            color: Color(0xFF1565C0)),
        RealWorldExample(
            title: 'AI Coding',
            subtitle: 'Writing and fixing code automatically',
            icon: '💻',
            color: Color(0xFF00838F)),
      ],
      sections: const [
        LearningSection(
            title: 'How It Works',
            icon: '⚙️',
            content:
                'Generative models learn patterns from massive datasets, then '
                'use a probabilistic model to sample new outputs that look '
                'similar to the training data. Large Language Models (LLMs) '
                'take this further by predicting tokens in sequence.'),
        LearningSection(
            title: 'Key Concepts',
            icon: '🧩',
            content:
                'Training data, neural networks, tokens, prompts, temperature, '
                'and fine-tuning are the building blocks you should understand '
                'before going deeper.'),
        LearningSection(
            title: 'Why It Matters',
            icon: '🚀',
            content:
                'Generative AI is transforming education, design, healthcare '
                'and software development. As a student, using it to learn is '
                'a superpower — exactly what this app demonstrates today.'),
      ],
    );
  }
LearningContent _flutterProfile(String topic) {
    return LearningContent(
      topic: 'Flutter',
      overview:
          'Flutter is Google\'s open-source UI toolkit for building natively '
          'compiled applications for mobile, web and desktop from a single '
          'Dart codebase. It is fast, expressive and loved for its '
          'beautiful UI and hot-reload experience.',
      flow: const [
        FlowStep(label: 'You write Dart code', icon: '✍️'),
        FlowStep(label: 'Widgets build the UI', icon: '🧱'),
        FlowStep(label: 'Flutter Engine renders', icon: '🎨'),
        FlowStep(label: 'Runs on any platform', icon: '📱'),
      ],
      examples: const [
        RealWorldExample(
            title: 'Material App',
            subtitle: 'The root widget of every Flutter app',
            icon: '📦',
            color: Color(0xFF0277BD)),
        RealWorldExample(
            title: 'Widgets',
            subtitle: 'Stateless & Stateful building blocks',
            icon: '🧩',
            color: Color(0xFF6A1B9A)),
        RealWorldExample(
            title: 'Hot Reload',
            subtitle: 'See changes instantly while coding',
            icon: '⚡',
            color: Color(0xFFEF6C00)),
        RealWorldExample(
            title: 'Single Codebase',
            subtitle: 'iOS, Android, Web & Desktop at once',
            icon: '🖥️',
            color: Color(0xFF2E7D32)),
      ],
      sections: const [
        LearningSection(
            title: 'Why Flutter?',
            icon: '🌟',
            content:
                'Fast UI rendering, expressive widgets, first-class tooling '
                'and a huge community make Flutter one of the smartest choices '
                'for cross-platform app development.'),
        LearningSection(
            title: 'Core Concepts',
            icon: '🧠',
            content:
                'Master widgets, the widget tree, StatefulWidget vs '
                'StatelessWidget, layouts, navigation, and state management '
                '(Provider / Riverpod / Bloc) to start building real apps.'),
        LearningSection(
            title: 'Your Path',
            icon: '🛣️',
            content:
                'Begin with Dart, then Flutter widgets, then state management, '
                'then APIs and Firebase. The roadmap generator below can build '
                'this path automatically for you.'),
      ],
    );
  }

  LearningContent _genericProfile(
    String topic,
    String intro,
    List<String> concepts,
    String applySentence,
  ) {
    return LearningContent(
      topic: topic,
      overview:
          '$intro\n\nIn this guide we break $topic down into simple, memorable '
          'ideas, walk through how it works, and show you how it is used in the '
          'real world.',
      flow: const [
        FlowStep(label: 'Learn the Basics', icon: '📖'),
        FlowStep(label: 'Core Concepts', icon: '🧠'),
        FlowStep(label: 'Practice', icon: '✏️'),
        FlowStep(label: 'Build & Apply', icon: '🚀'),
      ],
      examples: const [
        RealWorldExample(
            title: 'Real Apps',
            subtitle: 'Used daily by millions of users',
            icon: '📱',
            color: Color(0xFF0277BD)),
        RealWorldExample(
            title: 'Industry Jobs',
            subtitle: 'High demand for skills',
            icon: '💼',
            color: Color(0xFF2E7D32)),
        RealWorldExample(
            title: 'Projects',
            subtitle: 'Perfect for your portfolio',
            icon: '🛠️',
            color: Color(0xFF6A1B9A)),
      ],
      sections: [
        LearningSection(
          title: 'Core Concepts',
          icon: '🧠',
          content: concepts.map((c) => '• $c').join('\n'),
        ),
        const LearningSection(
            title: 'How to Learn',
            icon: '🛣️',
            content:
                'Study the fundamentals, then practice with small exercises '
                'and finally build a real project. Consistency beats '
                'intensity.'),
        LearningSection(
          title: 'Applying $topic',
          icon: '🚀',
          content: 'You can start by $applySentence. Small daily steps lead to '
              'mastery quickly.',
        ),
      ],
    );
  }

  List<String> _relativeConcepts(String topic) {
    final t = topic.isEmpty ? 'this topic' : topic;
    return [
      'Understanding the fundamentals of $t',
      'Practical examples of $t',
      'Common mistakes to avoid with $t',
      'Hands-on exercise for $t',
    ];
  }
// ---------------------------------------------------------------------------
  // Quiz
  // ---------------------------------------------------------------------------

  @override
  Future<Quiz> generateQuiz({
    required String topic,
    required int count,
    required String difficulty,
  }) async {
    await _think();
    final questions = <QuizQuestion>[];
    for (var i = 0; i < count; i++) {
      questions.add(_makeQuestion(topic, i + 1, difficulty));
    }
    return Quiz(
      topic: _extractTopic(topic),
      total: count,
      difficulty: difficulty,
      questions: questions,
    );
  }

  QuizQuestion _makeQuestion(String topic, int index, String difficulty) {
    final t = _extractTopic(topic);
    final difficultyPrefix = _difficultyPrefix(difficulty);
    switch (index % 4) {
      case 0:
        return QuizQuestion(
          question: 'What is $t?',
          options: const [
            QuizOption(label: 'A', text: 'AI that only stores data'),
            QuizOption(label: 'B', text: 'AI that creates new content'),
            QuizOption(label: 'C', text: 'A database'),
            QuizOption(label: 'D', text: 'A programming language'),
          ],
          correctLabel: 'B',
          explanation: '$t is about creating or processing content in a smart, '
              'structured way — not just storing raw data. That is the core of '
              'how Generative AI assists learning.',
        );
      case 1:
        return QuizQuestion(
          question: 'Which is a core benefit of learning $t?',
          options: [
            QuizOption(label: 'A', text: 'Forgetting everything quickly'),
            QuizOption(label: 'B', text: 'Only memorizing facts'),
            QuizOption(label: 'C', text: 'Building real, practical skills'),
            QuizOption(label: 'D', text: 'Avoiding practice'),
          ],
          correctLabel: 'C',
          explanation: '$difficultyPrefix The real value of $t comes from '
              'applying it to solve problems and build things.',
        );
      case 2:
        return QuizQuestion(
          question: 'How should you begin studying $t?',
          options: [
            QuizOption(label: 'A', text: 'Master every detail in one day'),
            QuizOption(label: 'B', text: 'Start with fundamentals & practice'),
            QuizOption(label: 'C', text: 'Skip the basics entirely'),
            QuizOption(label: 'D', text: 'Only watch videos, never code'),
          ],
          correctLabel: 'B',
          explanation: 'A solid foundation plus consistent hands-on practice is '
              'the most reliable study path for $t.',
        );
      default:
        return QuizQuestion(
          question: 'What best describes a strong learner of $t?',
          options: [
            QuizOption(label: 'A', text: 'Someone who never asks questions'),
            QuizOption(label: 'B', text: 'Someone who learns by doing'),
            QuizOption(label: 'C', text: 'Someone who only memorizes terms'),
            QuizOption(label: 'D', text: 'Someone who gives up easily'),
          ],
          correctLabel: 'B',
          explanation: 'Active learning — experimenting and building small '
              'projects — is how $t truly sticks.',
        );
    }
  }

  String _difficultyPrefix(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Starting from scratch: ';
      case 'intermediate':
        return 'Going deeper: ';
      case 'advanced':
        return 'Advanced insight: ';
      default:
        return '';
    }
  }
// ---------------------------------------------------------------------------
  // Roadmap
  // ---------------------------------------------------------------------------

  @override
  Future<Roadmap> generateRoadmap(String goal) async {
    await _think();
    return _buildRoadmap(_extractTopic(goal), goal);
  }

  Roadmap _buildRoadmap(String goal, String raw) {
    final lower = raw.toLowerCase();
    final topics = <String>[];
    if (_mentions(lower, ['flutter'])) {
      topics.addAll(const [
        'Programming Fundamentals',
        'Dart',
        'Flutter Basics',
        'State Management',
        'REST APIs',
        'Firebase',
        'Advanced Flutter',
        'Build Real Projects',
      ]);
    } else if (_mentions(lower, ['python', 'developer'])) {
      topics.addAll(const [
        'Python Fundamentals',
        'Data Structures & Algorithms',
        'OOP in Python',
        'Libraries: NumPy & Pandas',
        'Automation & Scripting',
        'Web APIs with Flask/FastAPI',
        'AI & Machine Learning Basics',
        'Build a Portfolio Project',
      ]);
    } else {
      topics.addAll(_relativeTopics(goal));
    }

    final steps = <RoadmapStep>[];
    for (var i = 0; i < topics.length; i++) {
      final difficulty = i < 2
          ? 'Beginner'
          : i < 5
              ? 'Intermediate'
              : 'Advanced';
      steps.add(
        RoadmapStep(
          step: i + 1,
          topic: topics[i],
          description:
              'Master ${topics[i]} with focused lessons and small exercises '
              'that build toward your goal of $goal.',
          duration: '${2 + (i % 3)} weeks',
          difficulty: difficulty,
        ),
      );
    }
    return Roadmap(goal: goal, steps: steps);
  }

  List<String> _relativeTopics(String goal) {
    final g = goal.isEmpty ? 'your goal' : goal;
    return [
      'Fundamentals of $g',
      'Core Concepts',
      'Hands-on Practice',
      'Tools & Libraries',
      'Mini Projects',
      'Community & Resources',
    ];
  }
// ---------------------------------------------------------------------------
  // Code
  // ---------------------------------------------------------------------------

  @override
  Future<CodeResult> generateCode(String prompt) async {
    await _think();
    return _buildCode(prompt);
  }

  CodeResult _buildCode(String prompt) {
    final lower = prompt.toLowerCase();
    final language = _requestedLanguage(lower);
    if (language == 'python') return _buildPythonCode(prompt, lower);
    if (language == 'javascript') return _buildJavaScriptCode(prompt);

    if (_mentions(lower, ['login']) || _mentions(lower, ['sign in'])) {
      return const CodeResult(
        title: 'Flutter Login Screen',
        language: 'dart',
        code: '''
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _login() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logging in as \${_email.text}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Welcome Back 👋',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _login,
                  child: const Text('Log In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''',
        explanation:
            'This creates a modern login form using a StatefulWidget to hold '
            'the email and password controllers. The layout is centered with a '
            'SingleChildScrollView so it works on small screens. Tapping Login '
            'shows a snackbar as a demo callback.',
        widgetsUsed: [
          'MaterialApp',
          'Scaffold',
          'Center',
          'SingleChildScrollView',
          'Column',
          'TextField',
          'FilledButton',
          'SnackBar',
        ],
      );
    }

    return const CodeResult(
      title: 'Flutter Counter App',
      language: 'dart',
      code: '''
int _count = 0;

void _increment() {
  setState(() => _count++);
}

FilledButton(
  onPressed: _increment,
  child: const Icon(Icons.add),
)
''',
      explanation:
          'A minimal example showing a stateful counter. The `_count` variable '
          'lives in State and `setState` triggers a rebuild so the UI always '
          'reflects the latest value.',
      widgetsUsed: ['StatefulWidget', 'setState', 'FilledButton'],
    );
  }

  String _requestedLanguage(String prompt) {
    if (_mentions(prompt, ['python', 'py script', 'django', 'flask'])) {
      return 'python';
    }
    if (_mentions(prompt, ['javascript', 'js', 'node', 'react'])) {
      return 'javascript';
    }
    if (_mentions(prompt, ['typescript', 'ts'])) return 'typescript';
    if (_mentions(prompt, ['java'])) return 'java';
    if (_mentions(prompt, ['kotlin'])) return 'kotlin';
    if (_mentions(prompt, ['swift'])) return 'swift';
    if (_mentions(prompt, ['c#', 'csharp', 'dotnet'])) return 'csharp';
    if (_mentions(prompt, ['dart', 'flutter', 'widget', 'screen'])) {
      return 'dart';
    }
    return 'dart';
  }

  CodeResult _buildPythonCode(String prompt, String lower) {
    final isLogin = _mentions(lower, ['login', 'sign in', 'authentication']);
    final code = isLogin
        ? '''
from getpass import getpass


def login(users):
    email = input("Email: ").strip()
    password = getpass("Password: ")
    if users.get(email) == password:
        print("Login successful")
        return True
    print("Invalid email or password")
    return False


if __name__ == "__main__":
    login({"student@example.com": "study123"})
'''
        : '''
def main():
    print("Hello from Python")


if __name__ == "__main__":
    main()
''';
    return CodeResult(
      title: isLogin ? 'Python Login Program' : 'Python Program',
      language: 'python',
      code: code,
      explanation: isLogin
          ? 'This Python example reads credentials securely with getpass, '
              'checks them against a sample user store, and reports the result.'
          : 'This is a small executable Python starting point for the requested '
              'task: $prompt.',
      widgetsUsed: const ['input', 'getpass', 'function'],
    );
  }

  CodeResult _buildJavaScriptCode(String prompt) {
    return CodeResult(
      title: 'JavaScript Program',
      language: 'javascript',
      code: '''
function main() {
  console.log('Hello from JavaScript');
}

main();
''',
      explanation: 'A runnable JavaScript starting point for: $prompt.',
      widgetsUsed: const ['function', 'console.log'],
    );
  }
// ---------------------------------------------------------------------------
  // Project idea
  // ---------------------------------------------------------------------------

  @override
  Future<ProjectIdea> generateProjectIdea({
    required String technology,
    required String difficulty,
  }) async {
    await _think();
    return _buildProject(technology, difficulty);
  }

  ProjectIdea _buildProject(String technology, String difficulty) {
    final tech = technology.isEmpty ? 'Full-Stack' : technology;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return ProjectIdea(
          name: 'Smart Expense Tracker',
          description:
              'An application that helps users track daily expenses using '
              'AI-based spending insights and simple visual reports.',
          features: const [
            'Expense tracking',
            'Category management',
            'AI spending analysis',
            'Monthly reports',
          ],
          technologies: [tech, 'Local database', 'Charts library'],
          difficulty: difficulty,
          estimatedTime: '2 - 3 weeks',
        );
      case 'intermediate':
        return ProjectIdea(
          name: 'Study Buddy Companion',
          description:
              'A personalized study planner that uses AI to generate notes, '
              'quizzes and revision reminders based on the user\'s subjects.',
          features: const [
            'AI note generation',
            'Auto-generated quizzes',
            'Smart reminders',
            'Progress tracking',
          ],
          technologies: [tech, 'Backend API', 'Authentication'],
          difficulty: difficulty,
          estimatedTime: '4 - 6 weeks',
        );
      default:
        return ProjectIdea(
          name: 'Health AI Assistant',
          description:
              'An AI-powered wellness assistant that analyzes activity data '
              'and delivers personalized health insights and recommendations.',
          features: const [
            'AI health insights',
            'Activity trends',
            'Personalized recommendations',
            'Data visualization',
          ],
          technologies: [tech, 'Machine Learning', 'Cloud services'],
          difficulty: difficulty,
          estimatedTime: '2 - 3 months',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _think() async {
    // Simulate real network + "thinking" latency for a believable demo.
    await Future<void>.delayed(
      _latency + Duration(milliseconds: _random.nextInt(500)),
    );
  }
}
