import 'package:flutter/material.dart';
import '../../core/theme.dart'; // تأكدي أن المسار يوصل لملف AppColors
import 'RouteSuggestionScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class LibraryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const LibraryDetailsScreen({super.key, required this.eventData});

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  bool isFavorite = false;
  bool isReminder = false;
  bool isAttending = false;
  double userRating = 5.0;
  String selectedCrowd = 'Low';
  TextEditingController commentController = TextEditingController();

  // دالة التأكد من تسجيل الدخول (لحماية الأزرار)
  bool _checkLoginAndShowMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in to interact"),
          backgroundColor: AppColors.primary, // لون الموف من الثيم
          action: SnackBarAction(
            label: "Login",
            textColor: Colors.white,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.eventData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(data['Category'] ?? "Details", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  // القسم الأيسر: الصورة والأزرار (القلب، الجرس، الكومنت)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Text(data['Title'] ?? "", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(data['Image_Url'] ?? '', fit: BoxFit.cover, height: 400, width: double.infinity),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            // 1. زر القلب (ينور أحمر)
                            IconButton(
                              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.black),
                              onPressed: () {
                                if (_checkLoginAndShowMessage()) setState(() => isFavorite = !isFavorite);
                              },
                            ),
                            // 2. زر الجرس (ينور موفي)
                            IconButton(
                              icon: Icon(isReminder ? Icons.notifications : Icons.notifications_none, color: isReminder ? AppColors.primary : Colors.black),
                              onPressed: () {
                                if (_checkLoginAndShowMessage()) setState(() => isReminder = !isReminder);
                              },
                            ),
                            // 3. زر الكومنت (يفتح واجهة الكتابة)
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () {
                                if (_checkLoginAndShowMessage()) _showCommentsSheet();
                              },
                            ),
                            const Spacer(),
                            // 4. زر الحضور (موفي)
                            ElevatedButton(
                              onPressed: () {
                                if (_checkLoginAndShowMessage()) {
                                  setState(() => isAttending = !isAttending);
                                  _updateInteraction('Is_Attending', isAttending);
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: isAttending ? Colors.green : AppColors.primary),
                              child: Text(isAttending ? "Attending" : "I'm attending", style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // القسم الأيمن: المعلومات والتعليقات
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("About", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(data['About'] ?? "No description."),
                        const SizedBox(height: 20),
                        const Text("Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        _detailRow("Schedule:", data['Schedule'] ?? "TBD"),
                        _detailRow("Price:", data['Price'] ?? "Free"),
                        _detailRow("Location:", data['Location_Address'] ?? "Riyadh"),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RouteSuggestionScreen())),
                          icon: const Icon(Icons.location_on, color: Colors.white),
                          label: const Text("Suggest a route", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        ),
                        const SizedBox(height: 30),
                        const Text("Reviews & Feedback", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        _buildReviewsStream(data['id']?.toString() ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- بقية الـ Widgets والـ Functions (نفس كودك الأصلي تماماً) ---
  
  Widget _buildReviewsStream(String eventId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Comment Feedback').where('id', isEqualTo: eventId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return ListView(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.docs.map((doc) => Card(
            child: ListTile(
              title: Text("Rating: ${doc['Rating']} ⭐"),
              subtitle: Text(doc['Comment_Text'] ?? ""),
            ),
          )).toList(),
        );
      },
    );
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Add Your Feedback", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextField(controller: commentController, decoration: const InputDecoration(hintText: "Your comment")),
          ElevatedButton(onPressed: _submitComment, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text("Submit", style: TextStyle(color: Colors.white))),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('Comment Feedback').add({
        'id': widget.eventData['id']?.toString() ?? '',
        'Comment_Text': commentController.text,
        'Rating': userRating,
        'Date': Timestamp.now(),
        'User_Name': user?.displayName ?? 'Guest',
      });
      commentController.clear();
      Navigator.pop(context);
    } catch (e) { print(e); }
  }

  Future<void> _updateInteraction(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      String docId = "${user.uid}_${widget.eventData['id']}";
      await FirebaseFirestore.instance.collection('User_Interactions').doc(docId).set({
        'User_Id': user.uid, 'id': widget.eventData['id'], field: value, 'Last_Update': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) { print(e); }
  }

  Widget _buildSearchBar() {
    return Container(width: 500, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(30)), child: const TextField(decoration: InputDecoration(hintText: "search", border: InputBorder.none, prefixIcon: Icon(Icons.search))));
  }

  Widget _detailRow(String title, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Text("$title ", style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)]));
  }
}