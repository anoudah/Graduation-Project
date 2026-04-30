import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart'; // تأكدي أن المسار يوصل لملف الثيم عندك
import 'interests_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String referral;
  final String correctOtp;

  const VerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.referral,
    required this.correctOtp,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyAndSignUp() async {
    // التحقق من تطابق الرمز
    if (_otpController.text.trim() == widget.correctOtp) {
      setState(() => _isLoading = true);
      try {
        // إنشاء الحساب في Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: widget.email,
              password: widget.password,
            );

        // حفظ البيانات في Firestore بنفس مسمياتك
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set({
              'User_Id': userCredential.user!.uid,
              'Full_Name': widget.name,
              'Email': widget.email,
              'Created_At': FieldValue.serverTimestamp(),
              'referral_code': widget.referral,
              'Profile_Image': "default_url",
              'dob': "",
              'gender': "",
              'is_admin': false,
              'selected_interests': [],
            });

        if (!mounted) return;

        // الانتقال لصفحة الاهتمامات
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InterestsScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? "Error occurred")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Incorrect Code!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Code",
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyAndSignUp,
                      child: const Text("Verify"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
