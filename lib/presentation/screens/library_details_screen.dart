import 'package:flutter/material.dart';
import '../../core/theme.dart';
// ignore: unused_import
import 'RouteSuggestionScreen.dart'; // تأكدي من مسمى الملف عندك
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

  // 1. فنكشن التأكد من تسجيل الدخول (ما لمستها)
  bool _checkLoginAndShowMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in to interact"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "Login",
            textColor: AppColors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  // 2. فنكشن التفاعل مع الفايربيس (حفظ البيانات - ما لمستها)
  Future<void> _updateInteraction(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String eventId = widget.eventData['id'] ?? '';
    if (eventId.isEmpty) return;

    String docId = "${user.uid}_$eventId";

    try {
      await FirebaseFirestore.instance
          .collection('User_Interactions')
          .doc(docId)
          .set({
            'User_Id': user.uid,
            'id': eventId,
            field: value,
            'Last_Update': Timestamp.now(),
          }, SetOptions(merge: true));

      if (field == 'Is_Attending') {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .update({
              'attendance_count': value
                  ? FieldValue.increment(1)
                  : FieldValue.increment(-1),
            });
      }
    } catch (e) {
      print("Error updating interaction: $e");
    }
  }

  // 3. فنكشن إرسال التعليق (ما لمستها)
  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String eventId = widget.eventData['id'] ?? '';
    if (commentController.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('Reviews').add({
        'Event_Id': eventId,
        'User_Name': user.displayName ?? 'Anonymous',
        'Comment': commentController.text,
        'Rating': userRating,
        'Crowd_Level': selectedCrowd,
        'Timestamp': Timestamp.now(),
      });
      commentController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error submitting comment: $e");
    }
  }

  // 4. واجهة كتابة التعليق (BottomSheet - ما لمستها)
  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                "Write a Review",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              // تقييم النجوم
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
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submitComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.eventData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          data['Category'] ?? "Details",
          style: const TextStyle(color: AppColors.textMain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderImage(data),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainTitle(data),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  _buildAboutSection(data),
                  const SizedBox(height: 30),
                  _buildDetailsGrid(data),
                  const SizedBox(height: 40),
                  _buildReviewsSection(data['id'] ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets البناء (كلها مرتبطة بالثيم) ---

  Widget _buildHeaderImage(Map<String, dynamic> data) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(data['Image_Url'] ?? ''),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainTitle(Map<String, dynamic> data) {
    return Text(
      data['Title'] ?? "No Title",
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _iconBtn(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          isFavorite ? Colors.red : AppColors.iconGrey,
          () {
            if (_checkLoginAndShowMessage()) {
              setState(() => isFavorite = !isFavorite);
              _updateInteraction('Favorite', isFavorite);
            }
          },
        ),
        _iconBtn(
          isReminder ? Icons.notifications : Icons.notifications_none,
          isReminder ? AppColors.primary : AppColors.iconGrey,
          () {
            if (_checkLoginAndShowMessage()) {
              setState(() => isReminder = !isReminder);
              _updateInteraction('Reminder', isReminder);
            }
          },
        ),
        _iconBtn(Icons.chat_bubble_outline, AppColors.iconGrey, () {
          if (_checkLoginAndShowMessage()) _showCommentsSheet();
        }),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            if (_checkLoginAndShowMessage()) {
              setState(() => isAttending = !isAttending);
              _updateInteraction('Is_Attending', isAttending);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isAttending ? Colors.green : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isAttending ? "Attending" : "I'm attending",
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 26),
      onPressed: onTap,
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data['About'] ?? "No description.",
          style: const TextStyle(
            color: AppColors.textMain,
            height: 1.5,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.calendar_today,
            "Schedule",
            data['Schedule'] ?? "TBD",
          ),
          const Divider(),
          _detailRow(Icons.attach_money, "Price", data['Price'] ?? "Free"),
          const Divider(),
          _detailRow(
            Icons.location_on,
            "Location",
            data['Location_Address'] ?? "Riyadh",
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Reviews')
              .where('Event_Id', isEqualTo: eventId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return Column(
              children: snapshot.data!.docs
                  .map(
                    (doc) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          doc['User_Name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(doc['Comment']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(doc['Rating'].toString()),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
