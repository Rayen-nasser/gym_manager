import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_energy/provider/gym_provider.dart';
import 'package:gym_energy/provider/members_provider.dart';
import 'package:gym_energy/screens/auth/login.dart';
import 'package:gym_energy/screens/home_screen.dart';
import 'package:gym_energy/themes/gym_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Ensure this file is present

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MembersProvider()..fetchMembers(),
        ),
        ChangeNotifierProvider(
          create: (context) => GymProvider()..loadGymData(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await _saveThemePreference(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Energy',
      theme: _isDarkMode ? GymThemes.darkTheme : GymThemes.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomeScreen(
              onThemeChanged: toggleTheme,
              isDarkMode: _isDarkMode,
            );
          } else {
            return LoginScreen();
          }
        },
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
