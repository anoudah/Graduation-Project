import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'interests_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. تعريف الكنترولرز لجميع الحقول الموجودة في الصورة
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  bool _isLoading = false;

  // متغيرات لمربعات الاختيار (Checkboxes)
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

  // 2. الدالة البرمجية للتسجيل معدلة لتشمل البيانات الجديدة
  Future<void> _handleSignUp() async {
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
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // حفظ البيانات في Firestore (بما في ذلك كود الإحالة)
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set({
              'Full_Name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'referral_code': _referralController.text.trim(),
              'created_at': Timestamp.now(),
            });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InterestsScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
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
      backgroundColor: const Color(0xFFF6F0F0),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B4B8A)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      const Text(
                        "WASEL",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B4B8A),
                          letterSpacing: 2,
                        ),
                      ),
                      const Text("Step One"),
                      const Text(
                        "Fill in your information",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // استخدام الميثود المساعدة لكل الحقول
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

                      // 3. إضافة الـ Checkboxes كما في الصورة
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

                      // زر التسجيل (Next)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B4B8A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // الميثود المساعدة للحقول (TextFormField)
  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (!hint.contains("Optional") && (value == null || value.isEmpty)) {
          return "Required field";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6B4B8A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ميثود مساعدة لإنشاء أسطر الاختيار (Checkbox Rows)
  Widget _buildCheckboxRow(String text, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6B4B8A),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
