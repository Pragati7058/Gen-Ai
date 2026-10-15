import 'dart:ui';

/// App-wide static strings and quick-action descriptors.
class AppConstants {
  AppConstants._();

  static const String appName = 'Genly';
  static const String tagline = 'Learn Smarter with Generative AI';
  static const String helloHeader = 'Hello Student 👋';
  static const String mainQuestion = 'What do you want to learn today?';
  static const String promptPlaceholder =
      'Ask anything... for example: Explain Generative AI';
  static const String generateButtonText = '✨ Generate with AI';
}

/// A single quick-action card shown on the home screen.
class QuickAction {
  final String label;
  final String icon;
  final String prompt;
  final Gradient gradient;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.prompt,
    required this.gradient,
  });
}

/// One-click demo prompts used in the workshop Demo Mode.
class DemoTemplate {
  final String label;
  final String prompt;
  final String icon;

  const DemoTemplate({
    required this.label,
    required this.prompt,
    required this.icon,
  });
}

/// Convenience type used to carry arbitrary generated results across
/// navigation without tight coupling to a single generated widget type.
// (AIResultType is defined in screens/processing_screen.dart.)
