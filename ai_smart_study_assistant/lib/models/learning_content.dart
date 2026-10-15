import 'package:flutter/material.dart';

/// A structured section of generated learning content (e.g. "How It Works").
class LearningSection {
  final String title;
  final String icon;
  final String content;
  final List<LearningSection>? subSections;

  const LearningSection({
    required this.title,
    required this.icon,
    required this.content,
    this.subSections,
  });
}

/// A single step in a visual flow (e.g. Data -> AI Model -> ...).
class FlowStep {
  final String label;
  final String icon;

  const FlowStep({required this.label, required this.icon});
}

/// A real-world example card (ChatGPT, Image Generation, ...).
class RealWorldExample {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;

  const RealWorldExample({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// Top level model returned by `AIService.generateLearningContent`.
class LearningContent {
  final String topic;
  final String overview;
  final List<FlowStep> flow;
  final List<RealWorldExample> examples;
  final List<LearningSection> sections;

  const LearningContent({
    required this.topic,
    required this.overview,
    required this.flow,
    required this.examples,
    required this.sections,
  });
}
