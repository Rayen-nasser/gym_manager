import 'package:flutter/material.dart';

class Localization {
  static const List<String> _supportedLanguages = ['ar'];

  // General
  static String get greeting => "مرحبًا بكم في تطبيقنا"; // Welcome to our app
  static String get appName => "تطبيق الطاقة الرياضية"; // Sports Energy App

  // Signup Screen
  static String get signupTitle => "تسجيل حساب جديد"; // Create a New Account
  static String get startJourney => "ابدأ رحلتك الرياضية اليوم"; // Start Your Fitness Journey Today
  static String get fullNameHint => "الاسم الكامل"; // Full Name
  static String get emailHint => "البريد الإلكتروني"; // Email
  static String get passwordHint => "كلمة المرور"; // Password
  static String get confirmPasswordHint => "تأكيد كلمة المرور"; // Confirm Password
  static String get createAccount => "إنشاء حساب"; // Create Account
  static String get alreadyHaveAccount => "لديك حساب؟ تسجيل الدخول"; // Already have an account? Login
  static String get signup => "التسجيل"; // Signup (newly added)

  // Login Screen
  static String get login => "تسجيل الدخول"; // Login
  static String get forgotPassword => "هل نسيت كلمة المرور؟"; // Forgot Password?
  static String get contactUs => "اتصل بنا"; // Contact Us

  // Other Messages
  static String get successMessage => "تم التسجيل بنجاح!"; // Successfully registered!
  static String get errorMessage => "حدث خطأ!"; // An error occurred!

  // Language Support Check
  static bool isSupportedLanguage(String languageCode) {
    return _supportedLanguages.contains(languageCode);
  }
}
