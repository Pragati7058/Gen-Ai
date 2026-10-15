import 'package:flutter_test/flutter_test.dart';

import 'package:ai_smart_study_assistant/app.dart';

void main() {
  testWidgets('App boots to splash then home screen', (tester) async {
    await tester.pumpWidget(const AIStudyApp());

    // Splash screen shows the app name/tagline.
    expect(find.text('Genly'), findsOneWidget);
    expect(find.textContaining('Learn Smarter'), findsOneWidget);

    // Wait past the splash delay (2.6s) and settle navigation.
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();

    // Home screen should now be visible with the main question.
    expect(find.text('What do you want to learn today?'), findsOneWidget);
  });
}
