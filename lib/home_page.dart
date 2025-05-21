import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'signup.dart';
import 'theme_provider.dart'; // Import ThemeProvider

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme
    String greetingMessage = _getGreetingMessage();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅ Dynamic Background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Hello, $greetingMessage!',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white // ✅ White text in dark mode
                      : Colors.black, // ✅ Black text in light mode
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              Image.asset(
                'lib/assets/Logo.png',
                height: 200.0,
              ),
              const SizedBox(height: 50.0),
              _buildButton(context, "Log-In", const LoginPage(), theme),
              const SizedBox(height: 20.0),
              _buildButton(context, "Sign-Up", const SignUpPage(), theme),
              const SizedBox(height: 30.0),
              _buildThemeToggleButton(context), // ✅ Theme Toggle Button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget page, ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page), // ✅ Correct Page Navigation
        );
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.0,
          color: theme.brightness == Brightness.dark
              ? Colors.white // ✅ White text in dark mode
              : Colors.black, // ✅ Black text in light mode
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 20.0),
        backgroundColor: theme.primaryColor, // ✅ Button color remains the same
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
      ),
      onPressed: () {
        themeProvider.toggleTheme(
          themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark,
        );
      },
    );
  }

  String _getGreetingMessage() {
    var hour = DateTime.now().hour;
    List<String> morningGreetings = [
      'Rise and Shine',
      'Good Morning',
      'Wishing You a Sunny Morning',
      'Top of the Morning'
    ];
    List<String> afternoonGreetings = [
      'Good Afternoon',
      'Hope You\'re Having a Great Day',
      'Enjoy Your Afternoon',
      'Have a Nice Afternoon'
    ];
    List<String> eveningGreetings = [
      'Good Evening',
      'Hope You Had a Great Day',
      'Relax, It\'s Evening Time',
      'Wishing You a Cozy Evening'
    ];

    if (hour < 12) {
      return morningGreetings[Random().nextInt(morningGreetings.length)];
    } else if (hour < 17) {
      return afternoonGreetings[Random().nextInt(afternoonGreetings.length)];
    } else {
      return eveningGreetings[Random().nextInt(eveningGreetings.length)];
    }
  }
}
