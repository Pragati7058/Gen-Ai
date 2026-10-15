import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/code_result.dart';
import '../models/learning_content.dart';
import '../models/project_idea.dart';
import '../models/quiz.dart';
import '../models/roadmap.dart';

/// Parses a raw JSON map (returned by any LLM in `json_object` mode) into the
/// strong-typed models used across the app.
///
/// This class is intentionally provider-agnostic: OpenAI, Groq (free) and any
/// future provider can share it. Every method takes the parsed map and a fully
/// built fallback model, so a bad or partial LLM response never produces an
/// empty or crashing UI.
class StructuredResultParser {
  const StructuredResultParser();

  List<Map<String, dynamic>> _listOfMaps(Object? value) {
    if (value == null) return const [];
    return (value as List? ?? const [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  String _str(Object? v, String fallback) =>
      v == null ? fallback : v.toString().trim();

  List<String> _stringList(Object? value) =>
      (value as List? ?? const []).map((e) => e.toString()).toList();

  Color _colorFor(String name) {
    switch (name.toLowerCase()) {
      case 'blue':
        return Colors.blue.shade500;
      case 'green':
        return Colors.green.shade500;
      case 'purple':
      case 'violet':
        return Colors.purple.shade400;
      case 'orange':
        return Colors.orange.shade500;
      case 'red':
        return Colors.red.shade400;
      case 'teal':
      case 'cyan':
        return Colors.teal.shade400;
      case 'pink':
        return Colors.pink.shade300;
      case 'yellow':
        return Colors.yellow.shade600;
      default:
        return AppColors.primary;
    }
  }

  RoadmapStep _roadmapStep(int index, Map<String, dynamic> m) => RoadmapStep(
        step: int.tryParse(_str(m['step'], '${index + 1}')) ?? (index + 1),
        topic: _str(m['topic'], 'Step ${index + 1}'),
        description: _str(m['description'], 'Learn this skill.'),
        duration: _str(m['duration'], '1 week'),
        difficulty: _str(m['difficulty'], 'Beginner'),
      );

  QuizQuestion _quizQuestion(Map<String, dynamic> m) {
    const labels = ['A', 'B', 'C', 'D'];
    final options = _listOfMaps(m['options']);
    final labelled = <QuizOption>[];
    for (final opt in options) {
      final label = _str(
          opt['label'], labels[labelled.length % labels.length]).toUpperCase();
      labelled.add(QuizOption(
        label: label,
        text: _str(opt['text'], _str(opt['option'], 'Option $label')),
      ));
    }
    return QuizQuestion(
      question: _str(m['question'], 'Untitled question'),
      options: labelled,
      correctLabel:
          _str(m['correctLabel'], _str(m['answer'], 'A')).toUpperCase(),
      explanation: _str(m['explanation'], 'No explanation provided.'),
    );
  }

  LearningSection _learningSection(Map<String, dynamic> m) {
    final sub = _listOfMaps(m['subSections']).map(_learningSection).toList();
    return LearningSection(
      title: _str(m['title'], 'Section'),
      icon: _str(m['icon'], '📘'),
      content: _str(m['content'], ''),
      subSections: sub.isNotEmpty ? sub : null,
    );
  }

  LearningContent learningContent(Object? json, LearningContent fallback) {
    final m = (json is Map<String, dynamic>) ? json : <String, dynamic>{};
    return LearningContent(
      topic: _str(m['topic'], fallback.topic),
      overview: _str(m['overview'], fallback.overview),
      flow: _listOfMaps(m['flow'])
          .map((f) => FlowStep(
                label: _str(f['label'], 'Step'),
                icon: _str(f['icon'], '➤'),
              ))
          .toList(),
      examples: _listOfMaps(m['examples'])
          .map((e) => RealWorldExample(
                title: _str(e['title'], 'Example'),
                subtitle: _str(e['subtitle'], ''),
                icon: _str(e['icon'], '✨'),
                color: _colorFor(_str(e['color'], '')),
              ))
          .toList(),
      sections: _listOfMaps(m['sections']).map(_learningSection).toList(),
    );
  }

  Quiz quiz(Object? json, Quiz fallback, String difficulty) {
    final m = (json is Map<String, dynamic>) ? json : <String, dynamic>{};
    final questions = _listOfMaps(m['questions']).map(_quizQuestion).toList();
    return Quiz(
      topic: _str(m['topic'], fallback.topic),
      total: questions.isNotEmpty ? questions.length : fallback.total,
      difficulty: _str(m['difficulty'], difficulty),
      questions: questions.isNotEmpty ? questions : fallback.questions,
    );
  }

  Roadmap roadmap(Object? json, Roadmap fallback, String goal) {
    final m = (json is Map<String, dynamic>) ? json : <String, dynamic>{};
    final entryList = _listOfMaps(m['steps']);
    final steps = <RoadmapStep>[];
    for (var i = 0; i < entryList.length; i++) {
      steps.add(_roadmapStep(i, entryList[i]));
    }
    return Roadmap(
      goal: _str(m['goal'], goal),
      steps: steps.isNotEmpty ? steps : fallback.steps,
    );
  }

  CodeResult code(Object? json, CodeResult fallback) {
    final m = (json is Map<String, dynamic>) ? json : <String, dynamic>{};
    return CodeResult(
      title: _str(m['title'], fallback.title),
      language: _str(m['language'], fallback.language),
      code: _str(m['code'], fallback.code),
      explanation: _str(m['explanation'], fallback.explanation),
      widgetsUsed: _stringList(m['widgetsUsed']).isNotEmpty
          ? _stringList(m['widgetsUsed'])
          : fallback.widgetsUsed,
    );
  }

  ProjectIdea project(Object? json, ProjectIdea fallback, String difficulty) {
    final m = (json is Map<String, dynamic>) ? json : <String, dynamic>{};
    return ProjectIdea(
      name: _str(m['name'], fallback.name),
      description: _str(m['description'], fallback.description),
      features: _stringList(m['features']).isNotEmpty
          ? _stringList(m['features'])
          : fallback.features,
      technologies: _stringList(m['technologies']).isNotEmpty
          ? _stringList(m['technologies'])
          : fallback.technologies,
      difficulty: _str(m['difficulty'], difficulty),
      estimatedTime: _str(m['estimatedTime'], fallback.estimatedTime),
    );
  }
}

