import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Core Imports ---
import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';

// --- Screen Imports ---
import 'home_screen.dart';
import 'signup_screen.dart'; // تأكدت إنه بنفس الاسم اللي قلتي عليه

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  // --- دالة استعادة كلمة المرور ---
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          dialogContext.loc.resetPassword,
          style: const TextStyle(color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dialogContext.loc.resetPasswordInstructions),
            const SizedBox(height: 15),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: dialogContext.loc.emailAddress,
                prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              dialogContext.loc.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (resetEmailController.text.isNotEmpty) {
                final resetLinkSentMessage = dialogContext.loc.resetLinkSent;
                final errorLabel = dialogContext.loc.error;

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: resetEmailController.text.trim(),
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(resetLinkSentMessage),
                    ),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text("$errorLabel: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text(
              dialogContext.loc.send,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final defaultErrorMessage = context.loc.error;
      final noUserFoundMessage = context.loc.noUserFound;
      final wrongPasswordMessage = context.loc.wrongPasswordProvided;

      try {
        // ١. عملية تسجيل الدخول في Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // ٢. جلب بيانات المستخدم من Firestore (عشان نضمن إن حسابه مربوط صح)
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          // إذا البيانات موجودة، ننتقل للهوم
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // إذا الشخص مسجل دخول بس ماله بيانات في Firestore (مثل حالة الـ Add User اليدوي)
          throw "User data not found in Database";
        }
      } on FirebaseAuthException catch (e) {
        // معالجة أخطاء الفايربيس (مثل باسوورد غلط)
        String message = defaultErrorMessage;
        if (e.code == 'user-not-found') {
          message = noUserFoundMessage;
        } else if (e.code == 'wrong-password') {
          message = wrongPasswordMessage;
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        // معالجة أي خطأ آخر
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
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
                        context.loc.welcomeBack,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        context.loc.loginToYourAccount,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 50),

                      // Email Field
                      _buildTextField(
                        context.loc.emailAddress,
                        Icons.email_outlined,
                        _emailController,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildTextField(
                        context.loc.password,
                        Icons.lock_outline,
                        _passwordController,
                        isPassword: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.iconGrey,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                            context.loc.forgotPassword,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            context.loc.login,
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Link to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.loc.dontHaveAnAccount,
                            style: const TextStyle(color: AppColors.textMain),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              context.loc.signup,
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
    Widget? suffixIcon,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textMain),
      validator: (value) =>
          (!isOptional && (value == null || value.isEmpty)) ? context.loc.requiredField : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
