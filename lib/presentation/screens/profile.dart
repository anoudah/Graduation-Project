import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// تعريف الألوان هنا مباشرة عشان تضمنين ما يطلع لك Undefined AppColors
class ProfileColors {
  static const Color primary = Color(0xFF6B4B8A); // الموفي حقك
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardGrey = Color(0xFFE0E0E0);
}

class ProfilePage extends StatefulWidget {
  final String? uid;
  const ProfilePage({Key? key, this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  // حل مشكلة الشاشة الحمراء: التأكد من تطابق الحروف الكبيرة
  String gender = 'Male'; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.uid == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          fullNameController.text = userDoc['fullName'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          
          // تأكدي من جلب القيمة وتحويل أول حرف لكبير لضمان عدم حدوث الخطأ
          String fetchedGender = userDoc['gender'] ?? 'Male';
          if (fetchedGender.isNotEmpty) {
            gender = fetchedGender[0].toUpperCase() + fetchedGender.substring(1).toLowerCase();
          }
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: ProfileColors.cardGrey,
              child: Icon(Icons.person, size: 50, color: ProfileColors.primary),
            ),
            const SizedBox(height: 30),
            _buildTextField("Full Name", fullNameController),
            const SizedBox(height: 20),
            _buildTextField("Email", emailController, enabled: false),
            const SizedBox(height: 20),
            
            // ويدجيت اختيار الجنس المصلحة
            _buildDropdownField("Gender", gender, ['Male', 'Female'], (String? newValue) {
              setState(() {
                gender = newValue!;
              });
            }),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (widget.uid != null) {
                  await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
                    'fullName': fullNameController.text,
                    'gender': gender,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}