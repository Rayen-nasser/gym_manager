import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_energy/localization.dart';
import 'package:gym_energy/screens/home_screen.dart';
import 'package:gym_energy/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_energy/screens/auth/login.dart' as auth_screens;

import '../../widgets/text_flied.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all fields";
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match";
        _isLoading = false;
      });
      return;
    }

    try {
      User? user = await _authService.signupWithEmail(email, password, fullName);
      if (user != null) {
        // Navigate to LoginScreen or directly to the main app screen
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        setState(() {
          _errorMessage = "Failed to sign up";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final widthFactor = isPortrait ? 0.85 : 0.6;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "ابدأ رحلتك",
                    style: GoogleFonts.cairo(
                      textStyle: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "سجل حساب جديد",
                    style: GoogleFonts.cairo(
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Full Name Input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: CustomTextField(
                      controller: _fullNameController,
                      label: Localization.fullNameHint,
                      icon: Icons.person,
                      validator: (value) => value!.isEmpty ? "Full name is required" : null,
                      textStyle: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: CustomTextField(
                      controller: _emailController,
                      label: Localization.emailHint,
                      icon: Icons.email,
                      validator: (value) => value!.isEmpty ? Localization.emailError : null,
                      textStyle: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: CustomTextField(
                      controller: _passwordController,
                      label: Localization.passwordHint,
                      icon: Icons.lock,
                      validator: (value) => value!.isEmpty ? Localization.passwordError : null,
                      textStyle: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyLarge,
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: CustomTextField(
                      controller: _confirmPasswordController,
                      label: Localization.confirmPasswordHint,
                      icon: Icons.lock,
                      validator: (value) => value != _passwordController.text ? "Passwords do not match" : null,
                      textStyle: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyLarge,
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Display Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.cairo(
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.red[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Signup Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                        Localization.signup,
                        style: GoogleFonts.cairo(
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigate to Login Screen
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => auth_screens.LoginScreen()),
                      );
                    },
                    child: Text(
                      "لديك حساب بالفعل؟ تسجيل الدخول",
                      style: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}