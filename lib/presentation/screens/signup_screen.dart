import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Core Imports ---
import '../../core/theme.dart'; // تأكد من المسار الصحيح لملف الثيم

// --- Screen Imports ---
import 'interests_screen.dart';

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
    // 1. Validation for inputs and terms
    if (_formKey.currentState!.validate()) {
      if (!_isDeclared || !_isAgreed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please agree to the terms and conditions"),
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }

      setState(() => _isLoading = true);

      try {
        // 2. Create account in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 3. Send the verification link to the email
        await userCredential.user!.sendEmailVerification();

        // 4. Save data to Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set({
              'User_Id': userCredential.user!.uid,
              'Full_Name': _nameController.text.trim(),
              'Email': _emailController.text.trim(),
              'Created_At': FieldValue.serverTimestamp(),
              'referral_code': _referralController.text.trim(),
              'Profile_Image': "default_url",
              'dob': "",
              'gender': "",
              'is_admin': false,
              'selected_interests': [],
            });

        if (!mounted) return;

        // 5. Show verification dialog
        showDialog(
          context: context,
          barrierDismissible: false, // Cannot close by clicking outside
          builder: (context) => AlertDialog(
            title: const Text("Verify Your Email"),
            content: const Text(
              "We've sent a verification link to your email. "
              "Please check your inbox, verify your account, then click 'Done'.",
            ),
            actions: [
              // Resend Button (To ensure the link is active and sent)
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification link resent!")),
                  );
                },
                child: const Text("Resend"),
              ),
              // Done Button (Checks the actual status)
              TextButton(
                onPressed: () async {
                  // Refresh user status from Firebase server
                  await FirebaseAuth.instance.currentUser?.reload();
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null && user.emailVerified) {
                    if (!context.mounted) return;
                    Navigator.pop(context); // Close dialog

                    // Move to Interests Screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InterestsScreen(),
                      ),
                    );
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Email not verified yet. Please click the link in your email.",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Done"),
              ),
            ],
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? "Error occurred")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
                      const Text(
                        "Step One",
                        style: TextStyle(color: AppColors.textMain),
                      ),
                      const Text(
                        "Fill in your information",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        "Full Name",
                        Icons.person_outline,
                        _nameController,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        "Email Address",
                        Icons.email_outlined,
                        _emailController,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        "Password",
                        Icons.lock_outline,
                        _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        "Confirm Password",
                        Icons.lock_reset_outlined,
                        _confirmPasswordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        "Referral Code (Optional)",
                        Icons.card_giftcard,
                        _referralController,
                      ),
                      const SizedBox(height: 20),

                      _buildCheckboxRow(
                        "I declare that the information provided is true and correct",
                        _isDeclared,
                        (val) => setState(() => _isDeclared = val!),
                      ),
                      _buildCheckboxRow(
                        "I have read and agree to the Terms & Conditions and Privacy Policy",
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
                          child: const Text(
                            "Next",
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: AppColors.textMain),
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
                            child: const Text(
                              "Login",
                              style: TextStyle(
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textMain),
      validator: (value) {
        if (!hint.contains("Optional") && (value == null || value.isEmpty)) {
          return "Required field";
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
