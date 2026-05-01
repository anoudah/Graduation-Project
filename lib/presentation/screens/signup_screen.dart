import 'package:flutter/material.dart';
import 'verification_screen.dart';
import 'dart:math'; // ضروري لتوليد الأرقام العشوائية
// --- Core Imports ---
import '../../core/theme.dart'; // تأكد من المسار الصحيح لملف الثيم
import '../../core/localization/localization_extension.dart';

// --- Screen Imports ---
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  bool _isLoading = false;
  bool _isDeclared = false;
  bool _isAgreed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_isDeclared || !_isAgreed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.pleaseAgreeToTerms),
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.loc.passwordsDoNotMatch)));
        return;
      }

      // --- بداية التعديل الدقيق ---

      // 1. توليد رمز عشوائي من 4 أرقام
      String otpCode = (Random().nextInt(9000) + 1000).toString();

      // 2. طباعة الرمز في الـ Console (للتجربة)
      print("Your OTP Code is: $otpCode");

      // 3. الانتقال لصفحة التحقق مع إرسال كافة البيانات التي أدخلها المستخدم
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            referral: _referralController.text.trim(),
            correctOtp: otpCode, // نرسل الرمز ليتم مقارنته هناك
          ),
        ),
      );

      // --- نهاية التعديل ---
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام الثيم للخلفية
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              // استخدام الثيم للون التحميل
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // استخدام الثيم للعنوان الرئيسي
                      const Text(
                        "WASEL",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.loc.stepOne,
                        style: const TextStyle(color: AppColors.textMain),
                      ),
                      Text(
                        context.loc.fillInYourInformation,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        context.loc.fullName,
                        Icons.person_outline,
                        _nameController,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        context.loc.emailAddress,
                        Icons.email_outlined,
                        _emailController,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        context.loc.password,
                        Icons.lock_outline,
                        _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        context.loc.confirmPassword,
                        Icons.lock_reset_outlined,
                        _confirmPasswordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        context.loc.referralCodeOptional,
                        Icons.card_giftcard,
                        _referralController,
                        isOptional: true,
                      ),
                      const SizedBox(height: 20),

                      _buildCheckboxRow(
                        context.loc.declareInfoTrue,
                        _isDeclared,
                        (val) => setState(() => _isDeclared = val!),
                      ),
                      _buildCheckboxRow(
                        context.loc.agreeToTermsPrivacy,
                        _isAgreed,
                        (val) => setState(() => _isAgreed = val!),
                      ),

                      const SizedBox(height: 30),

                      // استخدام الثيم لزر التسجيل
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            context.loc.next,
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.loc.alreadyHaveAnAccount,
                            style: const TextStyle(color: AppColors.textMain),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              context.loc.login,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textMain),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return context.loc.requiredField;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        // استخدام الثيم للأيقونات
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String text, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          // استخدام الثيم لعلامة الصح
          activeColor: AppColors.primary,
          checkColor: AppColors.white,
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textMain),
          ),
        ),
      ],
    );
  }
}
