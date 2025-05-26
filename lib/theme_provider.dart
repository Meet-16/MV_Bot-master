import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;// Default to system theme

  ThemeProvider() {
    loadTheme();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString());
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'ThemeMode.system';
    themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == themeString,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }
}