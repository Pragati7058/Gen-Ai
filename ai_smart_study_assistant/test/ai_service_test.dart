import 'package:flutter_test/flutter_test.dart';

import 'package:ai_smart_study_assistant/services/mock_ai_service.dart';

void main() {
  final service = MockAIService();

  test('keeps Python prompts in Python', () async {
    final result = await service.generateCode(
      'Write a Python login program with email and password',
    );

    expect(result.language, 'python');
    expect(result.code, contains('getpass'));
    expect(result.code, isNot(contains('package:flutter')));
  });

  test('keeps JavaScript prompts in JavaScript', () async {
    final result = await service.generateCode('Create a JavaScript login example');

    expect(result.language, 'javascript');
    expect(result.code, contains('console.log'));
  });

  test('keeps Flutter prompts in Dart', () async {
    final result = await service.generateCode('Create a Flutter login screen');

    expect(result.language, 'dart');
    expect(result.code, contains('package:flutter'));
  });
}
