import 'package:flutter/material.dart';
import 'RouteSuggestionScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class LibraryDetailsScreen extends StatefulWidget {
  // 1. Changed to expect a full Map of data instead of just an ID
  final Map<String, dynamic> eventData;

  const LibraryDetailsScreen({super.key, required this.eventData});

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  bool isFavorite = false;
  bool isReminder = false;
  bool isAttending = false;
  double userRating = 5.0; // للنجوم
  String selectedCrowd = 'Low'; // لتقرير الزحام
  TextEditingController commentController = TextEditingController();
  // دالة التأكد من تسجيل الدخول باللغة الإنجليزية
  bool _checkLoginAndShowMessage() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in to like, comment, or subscribe"),
          backgroundColor: const Color(0xFF6B4B8A), // نفس لون الجرس في كودك
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "Login",
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ),
      );
      return false; // يعني اليوزر غير مسجل
    }
    return true; // يعني اليوزر مسجل دخول
  }

  @override
  Widget build(BuildContext context) {
    // 2. Simply read the data passed from the previous screen! No FutureBuilder needed.
    final data = widget.eventData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildTopNav(data['Category'] ?? "تفاصيل"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildImageSection(data)),
                  const SizedBox(width: 40),
                  Expanded(flex: 1, child: _buildInfoSection(data)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Map<String, dynamic> data) {
    return Column(
      children: [
        Text(
          data['Title'] ?? "",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            data['Image_Url'] ?? '',
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 350,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 100),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // 1. Favorite Button (القلب)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () {
                if (_checkLoginAndShowMessage()) {
                  // الفلتر الجديد
                  setState(() => isFavorite = !isFavorite);
                  _updateInteraction('Favorite', isFavorite);
                }
              },
            ),

            // 2. Reminder Button (الجرس)
            IconButton(
              icon: Icon(
                isReminder ? Icons.notifications : Icons.notifications_none,
                color: isReminder ? const Color(0xFF6B4B8A) : Colors.black,
              ),
              onPressed: () {
                if (_checkLoginAndShowMessage()) {
                  // الفلتر الجديد
                  setState(() => isReminder = !isReminder);
                  _updateInteraction('Reminder', isReminder);

                  if (isReminder) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Reminder added successfully!"),
                      ),
                    );
                  }
                }
              },
            ),

            // 3. Comments Button (الأيقونة موجودة والبرنت للتأكد)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                if (_checkLoginAndShowMessage()) {
                  _showCommentsSheet();
                }
              },
            ),

            const Spacer(),

            // 4. I'm attending Button (الزر اللي أضفتي حقله بالفايربيس)
            ElevatedButton(
              onPressed: () {
                setState(() => isAttending = !isAttending);
                _updateInteraction('Is_Attending', isAttending);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAttending
                          ? "Attendance recorded!"
                          : "Attendance cancelled!",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAttending
                    ? Colors.green
                    : const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isAttending ? "Attending" : "I'm attending",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopNav(String category) {
    return Text(
      category,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 500,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "search",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(data['About'] ?? "لا يوجد وصف متوفر حالياً."),
        const SizedBox(height: 20),
        const Text(
          "Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        _buildDetailRow("Schedule:", data['Schedule'] ?? "غير محدد"),
        _buildDetailRow("Price:", data['Price'] ?? "مجاني"),
        _buildDetailRow("Location:", data['Location_Address'] ?? "الرياض"),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RouteSuggestionScreen(),
              ),
            );
          },
          icon: const Icon(Icons.location_on, color: Colors.white),
          label: const Text(
            "Suggest a route",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // دالة إظهار واجهة التعليقات (النجوم والزحام)
  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Your Feedback",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () =>
                        setSheetState(() => userRating = index + 1.0),
                  ),
                ),
              ),
              const Text("Crowd Level"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Low', 'Medium', 'High']
                    .map(
                      (level) => ChoiceChip(
                        label: Text(level),
                        selected: selectedCrowd == level,
                        onSelected: (val) {
                          if (val) setSheetState(() => selectedCrowd = level);
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(hintText: "Your comment"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _submitComment();
                  Navigator.pop(context);
                },
                child: const Text("Submit"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // دالة الحفظ في كولكشن Comment Feedback وتحديث إحصائيات الزحام
  Future<void> _submitComment() async {
    // 1. التحقق من هوية المستخدم
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 2. التأكد من وجود معرف الفعالية
    final eventId = widget.eventData['id']?.toString() ?? '';
    if (eventId.isEmpty) return;

    try {
      // -------------------------------------------------------
      // أولاً: حفظ سجل التعليق التفصيلي في كولكشن Comment Feedback
      // -------------------------------------------------------
      await FirebaseFirestore.instance.collection('Comment Feedback').add({
        'User_Id': user.uid,
        'id': eventId,
        'Rating': userRating,
        'crowd_report': selectedCrowd, // (Low, Medium, High)
        'Comment_Text': commentController.text,
        'Date': Timestamp.now(),
      });

      // -------------------------------------------------------
      // ثانياً: تحديث العدادات اللحظية في كولكشن Events (لتحليل الـ AI)
      // -------------------------------------------------------

      // تحديد الحقل المطلوب تحديثه بناءً على اختيار المستخدم
      String crowdField = '';
      if (selectedCrowd == 'Low') crowdField = 'report_low_count';
      if (selectedCrowd == 'Medium') crowdField = 'report_medium_count';
      if (selectedCrowd == 'High') crowdField = 'report_high_count';

      if (crowdField.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Events') // تأكدي من مطابقة اسم الكولكشن للي عندك
            .doc(eventId)
            .update({
              crowdField: FieldValue.increment(1),
              'Last_Feedback_Date':
                  Timestamp.now(), // يفيد في معرفة حداثة البيانات للـ AI
            });
      }

      // 3. تنظيف الحقل وإشعار المستخدم بنجاح الإرسال
      commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback!")),
        );
      }
    } catch (e) {
      // طباعة أي خطأ تقني في الـ Console للمطور
      print("Detailed Error in _submitComment: $e");
    }
  }

  Future<void> _updateInteraction(String field, bool value) async {
    // 1. التحقق من وجود مستخدم مسجل دخول
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 2. استخراج معرف الفعالية والتأكد من عدم خلوه
    final eventId = widget.eventData['id']?.toString() ?? '';
    if (eventId.isEmpty) return;

    // 3. إنشاء معرف فريد للمستند (يربط اليوزر بالفعالية) لمنع التكرار
    String docId = "${user.uid}_$eventId";

    try {
      // -------------------------------------------------------
      // أولاً: تحديث كولكشن User_Interactions (سجل المستخدم الخاص)
      // -------------------------------------------------------
      await FirebaseFirestore.instance
          .collection('User_Interactions')
          /* */
          .doc(docId)
          .set({
            'User_Id': user.uid,
            'id': eventId,
            field: value, // يحدث Favorite أو Reminder أو Is_Attending
            'Last_Update': Timestamp.now(),
          }, SetOptions(merge: true));

      // -------------------------------------------------------
      // ثانياً: تحديث العداد التلقائي في كولكشن Events (لصديقتك والـ AI)
      // -------------------------------------------------------
      if (field == 'Is_Attending') {
        await FirebaseFirestore.instance
            .collection('Events') // تأكدي أن هذا اسم الكولكشن في الفايربيس
            .doc(eventId)
            .update({
              // إذا value صحيحة يزيد 1، إذا خاطئة ينقص 1
              'attendance_count': value
                  ? FieldValue.increment(1)
                  : FieldValue.increment(-1),
            });
      }
    } catch (e) {
      // طباعة الخطأ في حال حدوث مشكلة في الاتصال
      print("Error updating interaction: $e");
    }
  }
}
