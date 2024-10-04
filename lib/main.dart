import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gym_energy/screens/dashboard/home_screen.dart';
import 'package:gym_energy/themes/gym_themes.dart';  // Updated import path
import 'package:shared_preferences/shared_preferences.dart';

import 'themes/gym_themes.dart';  // For theme persistence

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save theme preference
  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // Toggle theme
  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemePreference(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Energy',
      theme: _isDarkMode ? GymThemes.darkTheme : GymThemes.lightTheme,
      home: Directionality(
        textDirection: TextDirection.rtl, // RTL support for Arabic
        child: HomeScreen(
          onThemeChanged: toggleTheme,
          isDarkMode: _isDarkMode,
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          // Ensure proper text scaling
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}