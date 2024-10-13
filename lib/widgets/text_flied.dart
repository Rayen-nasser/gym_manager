import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_energy/localization.dart';
import 'package:gym_energy/screens/auth/signup.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final int maxLines;
  final TextStyle? textStyle;
  final bool? obscureText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
    this.textStyle,
    this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText ?? false,
      style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        errorStyle: GoogleFonts.cairo(
          textStyle: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ),
      validator: validator,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

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
                    "لا ألم لا مكافأة",
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
                    "إدارة صالة الألعاب الرياضية الخاصة بك",
                    style: GoogleFonts.cairo(
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email Input
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: CustomTextField(
                      controller: _emailController,
                      label: Localization.emailHint,
                      icon: Icons.email,
                      validator: (value) => value!.isEmpty ? Localization.emailError : null,
                      textStyle: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
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
                        textStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
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

                  // Login Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        Localization.login,
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

                  // Forgot Password
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _handleForgotPassword,
                    child: Text(
                      Localization.forgotPassword,
                      style: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Sign Up Navigation
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _navigateToSignup,
                    child: Text(
                      "ليس لديك حساب؟ التسجيل الآن",
                      style: GoogleFonts.cairo(
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        _errorMessage = null;
      });
      // Navigate to another screen on successful login
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  void _handleForgotPassword() {
    // Handle forgot password functionality
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }
}