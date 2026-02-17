import 'package:flutter/material.dart';
import 'interests_screen.dart'; // استدعاء صفحة الاهتمامات

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0), // نفس لون خلفية الهوم
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Logo أو اسم التطبيق
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

              // حقل الاسم
              _buildTextField("Full Name", Icons.person_outline),
              const SizedBox(height: 20),

              // حقل الإيميل
              _buildTextField("Email Address", Icons.email_outlined),
              const SizedBox(height: 20),

              // حقل الباسورد
              _buildTextField("Password", Icons.lock_outline, isPassword: true),
              const SizedBox(height: 40),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // بعد التسجيل نوديه لصفحة الاهتمامات
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InterestsScreen()),
                    );
                  },
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
                      // هنا مفروض يروح لصفحة الـ Login
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

  // Widget مساعد لبناء الحقول بسرعة
  Widget _buildTextField(String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
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
}