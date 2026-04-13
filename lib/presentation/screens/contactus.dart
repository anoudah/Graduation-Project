import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// استدعاء ملف الثيم
import '../../core/theme.dart'; 

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        title: const Text('Contact Us'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                'Get in touch',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.primary, 
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                'Full Name',
                Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email Address',
                Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildMultilineField(
                'Your Message',
                Icons.message_outlined,
                controller: _messageController,
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Send Message',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon, {
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.subtitle.copyWith(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: isPassword,
    );
  }

  Widget _buildMultilineField(
    String hint,
    IconData icon, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.subtitle.copyWith(color: AppColors.textHint),
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

  // void _submit() {
  // You can plug in your submission logic here (e.g., send to API)
  //  ScaffoldMessenger.of(context).showSnackBar(
  //    const SnackBar(content: Text('Your message has been sent!')),
  // );
  // _nameController.clear();
  //_emailController.clear();
  // _messageController.clear();
  // }
  
  // Norah's Update: Logic to send contact messages directly to Firestore
  Future<void> _submit() async {
    // 1. Validation to ensure no empty fields are sent to the database
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // 2. Sending data to 'Contact Us' collection in Firestore
      await FirebaseFirestore.instance.collection('Contact Us').add({
        'Full_Name': _nameController.text, // From Name TextField
        'Email': _emailController.text, // From Email TextField
        'Message_Text': _messageController.text, // From Message TextField
        'Created_At': FieldValue.serverTimestamp(), // Automatic server time
        'Is_Read': false, // Default status for new messages
        // بدلاً من 'User_Id': 'Guest_User'
        'User_Id': FirebaseAuth.instance.currentUser?.uid ?? 'Guest_User',
      });

      // 3. Confirm success to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your message has been sent successfully!'),
          ),
        );
      }

      // 4. Clear form fields after successful submission
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (e) {
      // 5. Error handling (e.g., connection issues)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }
}