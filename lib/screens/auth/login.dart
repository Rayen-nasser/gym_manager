import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:gym_energy/localization.dart'; // Import your localization file
import 'package:gym_energy/screens/auth/signup.dart';

class LoginScreen extends StatefulWidget { // Change to StatefulWidget to manage state
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final TextEditingController _emailController = TextEditingController(); // Email controller
  final TextEditingController _passwordController = TextEditingController(); // Password controller
  String? _errorMessage; // To hold error messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the device is in portrait or landscape mode
          bool isPortrait = constraints.maxHeight > constraints.maxWidth;
          double widthFactor = isPortrait ? 0.8 : 0.6; // Adjust the width factor for landscape

          return Stack(
            children: [
              // Background image with overlay
              // Container(
              //   decoration: const BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage('assets/gym_background.jpg'), // Add your background image here
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              // Dark overlay for better contrast
              Container(
                color: Colors.black.withOpacity(0.6),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Text
                      const Text(
                        "لا ألم لا مكافأة", // Arabic for "NO PAIN NO GAIN"
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "إدارة صالة الألعاب الرياضية الخاصة بك", // Arabic for "Manage Your Gym"
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Email Input
                      SizedBox(
                        width: constraints.maxWidth * widthFactor, // Adjust width based on orientation
                        child: TextField(
                          controller: _emailController, // Set the controller
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.email),
                            hintText: Localization.emailHint, // Use localization
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password Input
                      SizedBox(
                        width: constraints.maxWidth * widthFactor, // Adjust width based on orientation
                        child: TextField(
                          controller: _passwordController, // Set the controller
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.lock),
                            hintText: Localization.passwordHint, // Use localization
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Display Error Message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Login Button
                      SizedBox(
                        width: constraints.maxWidth * widthFactor, // Adjust width based on orientation
                        child: ElevatedButton(
                          onPressed: () async {
                            // Handle login logic here
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();

                            try {
                              await _auth.signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              // Navigate to the next screen after successful login
                              // Example: Navigator.pushReplacementNamed(context, '/home');
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _errorMessage = e.message; // Set the error message to display
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.greenAccent,
                          ),
                          child: Text(
                            Localization.login, // Use localization
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      // Forgot Password
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          // Handle forgot password
                        },
                        child: Text(
                          Localization.forgotPassword, // Use localization
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      // Sign Up Navigation
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(), // Navigate to SignupScreen
                            ),
                          );
                        },
                        child: Text(
                          "ليس لديك حساب؟ التسجيل الآن", // Arabic for "Don't have an account? Sign Up"
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
