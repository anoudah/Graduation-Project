import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Core Imports ---
import '../../core/theme.dart'; 

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (mounted) {
          // الانتقال للهوم سكرين بعد نجاح الدخول
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login Failed")),
        );
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 18, 
                          color: AppColors.textMain, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const Text(
                        "Login to your account",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 50),

                      // Email Field
                      _buildTextField(
                        "Email Address",
                        Icons.email_outlined,
                        _emailController,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildTextField(
                        "Password",
                        Icons.lock_outline,
                        _passwordController,
                        isPassword: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.iconGrey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: AppColors.primary, fontSize: 13),
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
                          child: const Text("Login", style: AppTextStyles.buttonText),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Link to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(color: AppColors.textMain)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const SignUpScreen())
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: AppColors.primary, 
                                fontWeight: FontWeight.bold
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppColors.textMain),
      validator: (value) => (value == null || value.isEmpty) ? "Required field" : null,
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