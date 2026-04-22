import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // عشان ننتقل للهوم بعد الاختيار
// استدعاء ملف الثيم
import '../../core/theme.dart'; 

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // قائمة الاهتمامات المتاحة
  final List<String> categories = [
    'Museums',
    'Libraries',
    'Heritage',
    'Arts',
    'Technology',
    'Conferences',
    'Traditional Food',
    'Festivals',
  ];

  // قائمة لحفظ الاهتمامات اللي اختارها المستخدم
  final List<String> selectedInterests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // تم الربط بالثيم
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Welcome to Wasel!",
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 28,
                  color: const Color(0xFF1A237E), // حافظت على اللون الكحلي الخاص بالترحيب
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Pick your interests to get a personalized AI tour plan.",
                style: AppTextStyles.subtitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // عرض الاهتمامات بشكل شبكة مرنة
              Expanded(
                child: Wrap(
                  spacing: 12, // المسافة الأفقية
                  runSpacing: 12, // المسافة الرأسية
                  children: categories.map((interest) {
                    final isSelected = selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedInterests.remove(interest);
                          } else {
                            selectedInterests.add(interest);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary // تم الربط بالثيم
                              : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // زر الحفظ والانتقال للهوم
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedInterests.isEmpty
                      ? null
                      : () async {
                          // 1. التأكد من هوية اليوزر (للحماية)
                          final user = FirebaseAuth.instance.currentUser;

                          if (user == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please login first"),
                                ),
                              );
                            }
                            return;
                          }

                          final String uid = user.uid;

                          try {
                            // 2. حفظ الاهتمامات في Firestore (تأكدي من المسمى المطابق لصورتك)
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc(uid)
                                .set({
                                  'selected_interests':
                                      selectedInterests, // الاسم المطابق للداتابيز عندك
                                  'Selection_Date':
                                      FieldValue.serverTimestamp(),
                                }, SetOptions(merge: true));

                            // 3. الانتقال للهوم بعد نجاح الحفظ
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Database Error: $e");
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // تم الربط بالثيم
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Continue to Home",
                    style: AppTextStyles.buttonText.copyWith(
                      color: Colors.white,
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
}