import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // هذا السطر اللي كان ناقصك
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // 1. ضمان تهيئة Flutter Widgets
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Firebase (هنا كان الخطأ الأحمر لأنه ما كان فيه Import فوق)
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Page',
      theme: ThemeData(primaryColor: Colors.purple, useMaterial3: true),
      // فحص حالة المستخدم: إذا مسجل دخول نرسل الـ UID لصفحة البروفايل
      home: ProfilePage(uid: FirebaseAuth.instance.currentUser?.uid),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String? uid; // إضافة متغير لاستقبال المعرف
  const ProfilePage({Key? key, this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  String? selectedGender; // هذا المتغير سيخزن القيمة المختارة (Male أو Female)
  String userEmail = ""; // سنخزن الإيميل هنا لعرضه
  // دالة جلب البيانات من Firestore

  @override
  void initState() {
    super.initState();
    _loadUserData(); // هذا السطر هو الذي سيقوم بتشغيل جلب البيانات فور فتح الصفحة
  }

  Future<void> _loadUserData() async {
    try {
      // نستخدم الـ uid اللي استلمناه من الـ Widget
      String? userId = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        var doc = await FirebaseFirestore.instance
            .collection('Users') // *** تأكدي من حرف U الكبير ***
            .doc(userId)
            .get();

        if (doc.exists) {
          // هنا السحر! نضع البيانات داخل الـ Controllers عشان تظهر في الـ UI
          setState(() {
            // استخدمي هذه الأسماء بالضبط كما هي في Firestore
            fullNameController.text =
                doc.data()?['Full_Name'] ?? ''; // تأكدي من حرف F و N كبير
            dateOfBirthController.text = doc.data()?['dob'] ?? '';
            selectedGender = doc.data()?['gender'];
            userEmail = doc.data()?['Email'] ?? "";
          });
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> _updateProfile() async {
    try {
      // 1. الحصول على UID المستخدم الحالي
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // 2. تنظيف البيانات (إزالة المسافات الزائدة من البداية والنهاية)
      String fName = fullNameController.text.trim();
      String lName = lastNameController.text.trim();

      // منطق دمج الاسم: إذا كان الاسم الأخير فارغاً لا تضف مسافة زائدة
      String combinedName = lName.isEmpty ? fName : '$fName $lName';

      // 3. تحديث الوثيقة في مجموعة 'Users'
      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'Full_Name': combinedName, // مطابق تماماً لاسم الحقل في Firestore
        'gender': selectedGender,
        'dob': dateOfBirthController.text.trim(), // تنظيف تاريخ الميلاد أيضاً
      });

      // 4. إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green, // إضافة لون أخضر للنجاح
          ),
        );
      }
    } catch (e) {
      // تسجيل الخطأ للمبرمج
      debugPrint("Error updating profile: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red, // إضافة لون أحمر للفشل
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E5F5),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),

          child: Column(
            children: [
              SizedBox(height: 40),

              Text(
                fullNameController.text.isEmpty
                    ? 'Welcome!'
                    : 'Welcome, ${fullNameController.text}!',

                style: TextStyle(
                  fontSize: 32,

                  fontWeight: FontWeight.bold,

                  color: Colors.purple[800],
                ),
              ),

              SizedBox(height: 30),

              Container(
                padding: EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(15),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),

                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,

                          backgroundColor: Colors.purple[200],

                          child: Icon(
                            Icons.person,

                            size: 40,

                            color: Colors.purple[800],
                          ),
                        ),

                        SizedBox(width: 15),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              '${fullNameController.text}',

                              style: TextStyle(
                                fontSize: 18,

                                fontWeight: FontWeight.bold,

                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              userEmail,

                              style: TextStyle(
                                fontSize: 14,

                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed:
                          _updateProfile, // استبدلي الأقواس الفارغة باسم دالة التحديث

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: Text(
                        'Edit',

                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              Container(
                padding: EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(15),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),

                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // حقل الاسم الكامل الموحد
                    Text(
                      'Full Name',

                      style: TextStyle(
                        fontSize: 12,

                        fontWeight: FontWeight.w600,

                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 8),

                    TextField(
                      controller: fullNameController,

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,

                          vertical: 12,
                        ),
                      ),
                    ),

                    // توقفي هنا.. لا تغلقي الـ Column والـ Container الآن

                    // لأننا سنضيف حقول (الجنس وتاريخ الميلاد) تحت هذا الحقل مباشرة.
                    SizedBox(height: 20),

                    Row(
                      children: [
                        // حقل الجنس (Dropdown)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Gender',

                                style: TextStyle(
                                  fontSize: 12,

                                  fontWeight: FontWeight.w600,

                                  color: Colors.grey[600],
                                ),
                              ),

                              SizedBox(height: 8),

                              DropdownButtonFormField<String>(
                                value: selectedGender,

                                items: ['Male', 'Female', 'Other']
                                    .map(
                                      (gender) => DropdownMenuItem(
                                        value: gender,

                                        child: Text(gender),
                                      ),
                                    )
                                    .toList(),

                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },

                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,

                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 15),

                        // حقل تاريخ الميلاد
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Date of Birth',

                                style: TextStyle(
                                  fontSize: 12,

                                  fontWeight: FontWeight.w600,

                                  color: Colors.grey[600],
                                ),
                              ),

                              SizedBox(height: 8),

                              TextField(
                                controller: dateOfBirthController,

                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,

                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ], // نهاية الـ children للـ Column داخل الـ Container الأبيض
                ),
              ), // نهاية الـ Container الأبيض الخاص بالبيانات

              SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Your comments',

                  style: TextStyle(
                    fontSize: 18,

                    fontWeight: FontWeight.bold,

                    color: Colors.purple[800],
                  ),
                ),
              ),

              SizedBox(height: 15),

              _buildCommentCard(
                'Sarah Ahmed',
                '1 month ago',
                'kinda crowded but nice',
              ),

              SizedBox(height: 12),

              _buildCommentCard('Sarah Ahmed', '1 month ago', 'recommended'),

              SizedBox(height: 30),

              Container(
                padding: EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(15),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),

                      blurRadius: 10,
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.purple[400], size: 24),

                    SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Email Address',

                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          userEmail, // استخدمنا المتغير اللي عرفتيه فوق

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
            ], // نهاية الـ Column الرئيسية
          ),
        ), // نهاية الـ Padding
      ), // نهاية الـ SingleChildScrollView
    ); // نهاية الـ Scaffold
  } // نهاية الـ build method

  // --- دالة تنظيف الذاكرة (يجب أن تكون داخل الكلاس) ---
  @override
  void dispose() {
    fullNameController.dispose();
    dateOfBirthController.dispose();
    // تأكدي من إضافة أي Controller جديد هنا
    super.dispose();
  }

  // --- دالة بناء كرت التعليقات (يجب أن تكون داخل الكلاس) ---
  Widget _buildCommentCard(String username, String time, String comment) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // حماية الواجهة من الأسماء الطويلة جداً
              Expanded(
                child: Text(
                  username,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
} // <--- تأكدي أن هذا هو القوس الوحيد في نهاية الملف لإغلاق الكلاس
