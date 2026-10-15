import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../core/responsive_utils.dart';
import '../widgets/animated_ai_orb.dart';
import '../widgets/gradient_background.dart';
import 'home_screen.dart';

/// Modern animated splash screen shown on app launch.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _textOpacity =
      CurvedAnimation(parent: _fade, curve: Curves.easeOut);

  late final Animation<double> _slide =
      Tween<double>(begin: 0.06, end: 0).animate(
    CurvedAnimation(parent: _fade, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fade.forward();
    _navigateAway();
  }

  Future<void> _navigateAway() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    // Use a fade-through transition to the home screen.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    // Responsive sizing based on device type
    final orbSize = AppResponsive.isSmallPhone(context) ? 100.0 :
                    AppResponsive.isPhone(context) ? 120.0 :
                    AppResponsive.isTablet(context) ? 160.0 : 200.0;
    
    final titleSize = AppResponsive.responsiveFontSize(context, min: 24, max: 40);
    final taglineSize = AppResponsive.responsiveFontSize(context, min: 14, max: 20);
    final poweredFontSize = AppResponsive.responsiveFontSize(context, min: 11, max: 14);
    
    final screenPadding = AppResponsive.screenPadding(context);
    final bottomPad = AppResponsive.spacing(context, multiplier: 3);
    
    return Scaffold(
      body: GradientBackground(
        includeGlow: true,
        child: SafeArea(
          child: Padding(
            padding: screenPadding,
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedAIOrb(size: orbSize),
                AppResponsive.verticalSpace(context, multiplier: 2),
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(_slide),
                    child: Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: titleSize,
                                color: scheme.onSurface,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        AppResponsive.verticalSpace(context, multiplier: 2),
                        Text(
                          AppConstants.tagline,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                fontSize: taglineSize,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPad),
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      'Powered by ${AppConstants.appName.split(' ').last}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant.withValues(alpha:0.7),
                        fontSize: poweredFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}