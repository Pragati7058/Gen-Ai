import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/ai_service.dart';
import 'services/ai_service_factory.dart';

/// Root widget wiring up providers, theming and the app navigator.
///
/// The default provider comes from [AIServiceFactory]: it automatically uses
/// Groq when `GROQ_API_KEY` is supplied and otherwise falls back to the
/// offline mock engine. No UI changes are required when you switch providers.
class AIStudyApp extends StatelessWidget {
  final AIService? service;

  const AIStudyApp({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider<AIService>(
          create: (_) => service ?? AIServiceFactory.createDefault(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'AI Smart Study Assistant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
