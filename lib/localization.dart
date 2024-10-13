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
  static String get signup => "التسجيل"; // Signup

  // Login Screen
  static String get login => "تسجيل الدخول"; // Login
  static String get forgotPassword => "هل نسيت كلمة المرور؟"; // Forgot Password?
  static String get contactUs => "اتصل بنا"; // Contact Us

  // Error Messages
  static String get emailError => "الرجاء إدخال بريد إلكتروني صالح"; // Please enter a valid email
  static String get passwordError => "يجب أن تتكون كلمة المرور من 6 أحرف على الأقل"; // Password must be at least 6 characters

  // Other Messages
  static String get successMessage => "تم التسجيل بنجاح!"; // Successfully registered!
  static String get errorMessage => "حدث خطأ!"; // An error occurred!

  // Membership Screen
  static Map<String, String> get membershipTranslations => {
    'new_client': 'إضافة عميل جديد',
    'loading': 'جاري المعالجة...',
    'membership_type': 'نوع العضوية',
    'client': 'فردي',
    'trainer': 'مدرب',
    'personal_info': 'المعلومات الشخصية',
    'subscription_details': 'تفاصيل الاشتراك',
    'first_name': 'الاسم الأول',
    'last_name': 'اسم العائلة',
    'email': 'البريد الإلكتروني',
    'phone': 'رقم الهاتف',
    'enter_first_name': 'الرجاء إدخال الاسم الأول',
    'enter_last_name': 'الرجاء إدخال اسم العائلة',
    'enter_email': 'الرجاء إدخال البريد الإلكتروني',
    'enter_valid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
    'enter_phone': 'الرجاء إدخال رقم الهاتف',
    'membership_details': 'تفاصيل العضوية',
    'expiry_date': 'تاريخ انتهاء العضوية',
    'initial_payment': 'مبلغ الدفع الأولي',
    'currency': 'ر.س',
    'enter_amount': 'الرجاء إدخال مبلغ الدفع',
    'enter_valid_amount': 'الرجاء إدخال مبلغ صحيح',
    'select_trainer': 'اختيار المدرب',
    'choose_trainer': 'الرجاء اختيار المدرب',
    'sports_to_teach': 'الرياضات التي يقوم بتدريبها',
    'sports_to_join': 'الرياضات المراد الاشتراك بها',
    'select_sport': 'الرجاء اختيار رياضة واحدة على الأقل',
    'additional_notes': 'ملاحظات إضافية',
    'notes': 'ملاحظات',
    'add_notes': 'أضف أي ملاحظات إضافية هنا',
    'add_client_button': 'إضافة العميل',
    'fill_required': 'الرجاء تعبئة جميع الحقول المطلوبة',
    'success': 'تمت إضافة العميل بنجاح',
    'error': 'حدث خطأ أثناء إضافة العميل',
    'phone_length_error': 'رقم الهاتف يجب أن يتكون من 8 أرقام.'
  };

  // Language Support Check
  static bool isSupportedLanguage(String languageCode) {
    return _supportedLanguages.contains(languageCode);
  }
}
