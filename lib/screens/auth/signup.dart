import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:gym_energy/localization.dart'; // Import your localization file
import 'package:gym_energy/services/auth_service.dart'; // Import AuthService
import 'package:gym_energy/screens/auth/login.dart'; // Import the LoginScreen

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // To manage loading state

  // Method to handle signup logic
  Future<void> _handleSignup() async {
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading state
    });

    try {
      User? user = await _authService.signupWithEmail(email, password);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User signed up: ${user.email}")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to sign up")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // End loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isPortrait = constraints.maxHeight > constraints.maxWidth;
          double widthFactor = isPortrait ? 0.8 : 0.5; // Adjust the width factor for landscape

          return Stack(
            children: [
              // Background image with overlay
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/gym_background.jpg'), // Add your background image here
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dark overlay for better contrast
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "ابدأ رحلتك", // Arabic for "Start Your Journey"
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "سجل حساب جديد", // Arabic for "Sign up for a new account"
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name Input
                      SizedBox(
                        width: constraints.maxWidth * widthFactor,
                        child: TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            prefixIcon: const Icon(Icons.person),
                            hintText: Localization.fullNameHint, // Use localization
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Email Input
                      SizedBox(
                        width: constraints.maxWidth * widthFactor,
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            prefixIcon: const Icon(Icons.email),
                            hintText: Localization.emailHint, // Use localization
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password Input
                      SizedBox(
                        width: constraints.maxWidth * widthFactor,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            prefixIcon: const Icon(Icons.lock),
                            hintText: Localization.passwordHint, // Use localization
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password Input
                      SizedBox(
                        width: constraints.maxWidth * widthFactor,
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            prefixIcon: const Icon(Icons.lock),
                            hintText: Localization.confirmPasswordHint, // Use localization
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Signup Button
                      SizedBox(
                        width: constraints.maxWidth * widthFactor,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup, // Handle signup logic
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.greenAccent,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Text(
                            Localization.signup, // Use localization
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Navigate to Login Screen
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(), // Navigate to LoginScreen
                            ),
                          );
                        },
                        child: Text(
                          "لديك حساب بالفعل؟ تسجيل الدخول", // Arabic for "Already have an account? Log In"
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 16,
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
