import 'package:flutter/material.dart';

/// ChangeNotifier that controls the light/dark mode of the app.
class ThemeController extends ChangeNotifier {
  ThemeController({Brightness initialBrightness = Brightness.dark})
      : _brightness = initialBrightness;

  Brightness _brightness;

  Brightness get brightness => _brightness;

  bool get isDark => _brightness == Brightness.dark;

  ThemeMode get themeMode =>
      isDark ? ThemeMode.dark : ThemeMode.light;

  void toggle() {
    _brightness = isDark ? Brightness.light : Brightness.dark;
    notifyListeners();
  }

  void setBrightness(Brightness value) {
    if (_brightness == value) return;
    _brightness = value;
    notifyListeners();
  }
}
