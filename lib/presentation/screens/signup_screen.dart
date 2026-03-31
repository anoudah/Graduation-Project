import 'package:flutter/material.dart';
import 'interests_screen.dart'; // تأكدي أن هذا الملف موجود في مشروعك
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. تعريف الكنترولرز لإدارة النص المدخل (مثل كود صديقتك)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // تنظيف الذاكرة عند إغلاق الصفحة
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                "WASEL",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B4B8A),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Create an account to explore Saudi culture"),
              const SizedBox(height: 50),

              // 2. استخدام الميثود المعدلة مع الكنترولرز
              _buildTextField("Full Name", Icons.person_outline, controller: _nameController),
              const SizedBox(height: 20),

              _buildTextField("Email Address", Icons.email_outlined, controller: _emailController),
              const SizedBox(height: 20),

              _buildTextField("Password", Icons.lock_outline, isPassword: true, controller: _passwordController),
              const SizedBox(height: 40),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSignUp, // استدعاء دالة التسجيل
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4B8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
                    },
                    child: const Text("Login", style: TextStyle(color: Color(0xFF6B4B8A), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. تحديث الميثود المساعدة لتستقبل الكنترولر (تطابق كود صديقتك)
  Widget _buildTextField(String hint, IconData icon, {required TextEditingController controller, bool isPassword = false}) {
    return TextField(
      controller: controller, // ربط الحقل بالكنترولر
      obscureText: isPassword,
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

  // 4. دالة التعامل مع ضغطة الزر
  void _handleSignUp() {
    if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
      // إذا البيانات موجودة، ننتقل لصفحة الاهتمامات
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InterestsScreen()),
      );
    } else {
      // إظهار تنبيه إذا الحقول فارغة (اختياري)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }
}