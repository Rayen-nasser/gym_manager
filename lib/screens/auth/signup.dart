import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_energy/localization.dart';
import 'package:gym_energy/screens/home_screen.dart';
import 'package:gym_energy/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_energy/screens/auth/login.dart' as auth_screens;
import 'package:another_flushbar/flushbar.dart';

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

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
    });

    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validate full name
    if (fullName.isEmpty) {
      _showGuidance("الاسم الكامل مطلوب", "يرجى إدخال اسمك الكامل لإنشاء حساب شخصي", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate email
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showGuidance("البريد الإلكتروني غير صالح", "يرجى إدخال عنوان بريد إلكتروني صالح (مثال: user@example.com)", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate password
    if (password.length < 8) {
      _showGuidance("كلمة المرور قصيرة جدًا", "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل لضمان الأمان", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      _showGuidance("كلمات المرور غير متطابقة", "تأكد من إدخال نفس كلمة المرور في كلا الحقلين", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      User? user = await _authService.signupWithEmail(email, password, fullName);

      if (user != null) {
        // Successfully signed up
        setState(() {
          _isLoading = false;
        });
        _showGuidance("تم إنشاء الحساب بنجاح", "مرحبًا بك في تطبيق إدارة صالة الألعاب الرياضية! يمكنك الآن تسجيل الدخول", Colors.green);

        // Navigate to HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showGuidance("فشل في إنشاء الحساب", "حدث خطأ أثناء إنشاء حسابك. يرجى المحاولة مرة أخرى لاحقًا", Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "هذا البريد الإلكتروني مسجل بالفعل. هل تريد تسجيل الدخول بدلاً من ذلك؟";
          break;
        case 'weak-password':
          message = "كلمة المرور ضعيفة جدًا. يرجى اختيار كلمة مرور أقوى تحتوي على أحرف وأرقام ورموز";
          break;
        default:
          message = "حدث خطأ أثناء التسجيل: ${e.message}";
      }
      _showGuidance("خطأ في التسجيل", message, Colors.red);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showGuidance("خطأ غير متوقع", "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا", Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showGuidance(String title, String message, Color color) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 5),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        color == Colors.green ? Icons.check_circle :
        color == Colors.orange ? Icons.info_outline : Icons.error,
        color: Colors.white,
      ),
      titleText: Text(
        title,
        style: GoogleFonts.cairo(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.cairo(
          textStyle: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    ).show(context);
  }


  void _showFlushbar({required String message, required Color color}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(
        color == Colors.green ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
    ).show(context);
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
                      validator: (value) => value!.isEmpty ? "الاسم الكامل مطلوب" : null,
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
                      validator: (value) => value != _passwordController.text ? "كلمات المرور غير متطابقة" : null,
                      textStyle: GoogleFonts.cairo(
                        textStyle: theme.textTheme.bodyLarge,
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 30),

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