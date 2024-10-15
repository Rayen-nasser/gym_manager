import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_energy/localization.dart';
import 'package:gym_energy/screens/auth/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_energy/screens/home_screen.dart';
import 'package:another_flushbar/flushbar.dart';

import '../../widgets/text_flied.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validate email
    if (email.isEmpty) {
      _showGuidance("البريد الإلكتروني مطلوب", "يرجى إدخال عنوان بريد إلكتروني للمتابعة", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showGuidance("البريد الإلكتروني غير صالح", "يرجى إدخال عنوان بريد إلكتروني صالح (مثال: user@example.com)", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate password
    if (password.isEmpty) {
      _showGuidance("كلمة المرور مطلوبة", "يرجى إدخال كلمة المرور للمتابعة", Colors.orange);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _showGuidance("تم تسجيل الدخول بنجاح", "مرحبًا بعودتك إلى تطبيق إدارة صالة الألعاب الرياضية!", Colors.green);
        // Navigate to HomeScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "لم يتم العثور على حساب بهذا البريد الإلكتروني. هل ترغب في إنشاء حساب جديد؟";
          break;
        case 'wrong-password':
          message = "كلمة المرور غير صحيحة. يرجى التحقق من كلمة المرور وإعادة المحاولة";
          break;
        case 'user-disabled':
          message = "تم تعطيل هذا الحساب. يرجى الاتصال بالدعم للمساعدة";
          break;
        case 'too-many-requests':
          message = "تم تجاوز عدد محاولات تسجيل الدخول. يرجى المحاولة مرة أخرى لاحقًا";
          break;
        default:
          message = "حدث خطأ أثناء تسجيل الدخول: ${e.message}";
      }
      _showGuidance("خطأ في تسجيل الدخول", message, Colors.red);
    } catch (e) {
      _showGuidance("خطأ غير متوقع", "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقًا", Colors.red);
    } finally {
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

  void _handleForgotPassword() {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showGuidance("البريد الإلكتروني مطلوب", "يرجى إدخال عنوان بريد إلكتروني لإعادة تعيين كلمة المرور", Colors.orange);
      return;
    }

    _auth.sendPasswordResetEmail(email: email).then((_) {
      _showGuidance("تم إرسال رابط إعادة التعيين", "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني", Colors.green);
    }).catchError((error) {
      _showGuidance("خطأ في إعادة تعيين كلمة المرور", "حدث خطأ أثناء إرسال رابط إعادة التعيين. يرجى التحقق من البريد الإلكتروني والمحاولة مرة أخرى", Colors.red);
    });
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
                      textStyle: GoogleFonts.cairo(),
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
                      textStyle: GoogleFonts.cairo(),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
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
}