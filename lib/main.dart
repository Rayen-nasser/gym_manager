import 'package:flutter/material.dart';
import 'package:gym_energy/screens/auth/signup.dart'; // Ensure you have this file set up
import 'package:firebase_core/firebase_core.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Energy',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.green,
      ),
      locale: Locale('ar', ''), // Set locale to Arabic
      home: Directionality(
        textDirection: TextDirection.rtl, // Wrap your home in Directionality
        child: SignupScreen(), // Replace with your desired home screen
      ),
    );
  }
}
