import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/event_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. جلب معرف المستخدم الحالي (UID) لضمان خصوصية البيانات
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0),
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6B4B8A),
        centerTitle: true,
        elevation: 0,
      ),
      // 2. إذا لم يكن هناك يوزر مسجل، نطلب منه تسجيل الدخول
      body: userId == null
          ? const Center(child: Text("Please login to see favorites"))
          : StreamBuilder<QuerySnapshot>(
              // 3. نراقب جدول التفاعلات لليوزر الحالي والفعاليات التي حددها كمفضلة
              stream: FirebaseFirestore.instance
                  .collection('User_Interactions')
                  .where('User_Id', isEqualTo: userId)
                  .where('Favorite', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No favorites found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var interaction = snapshot.data!.docs[index];
                    // نأخذ الـ ID الخاص بالإيفنت من التفاعل (مثل: conf_01)
                    String eventId = interaction['Event_Id'];

                    // 4. جلب تفاصيل الفعالية المحددة من جدول Events
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Events')
                          .doc(eventId)
                          .get(),
                      builder: (context, eventSnapshot) {
                        if (!eventSnapshot.hasData ||
                            !eventSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        // تحويل بيانات الفعالية لخريطة (Map) ليسهل قراءتها
                        var eventData =
                            eventSnapshot.data!.data() as Map<String, dynamic>;

                        // 5. ربط البيانات الحقيقية بالـ EventCard (حسب كل إيفنت)
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EventCard(
                            // المسميات مطابقة تماماً لما في الفايربيز عندك
                            title: eventData['Title'] ?? 'No Title',
                            imagePath: eventData['Image_Url'] ?? '',
                            description: eventData['About'] ?? '',
                            schedule: eventData['Schedule'] ?? '',
                            price: eventData['Price'] ?? 'Free',
                            // سحب حالة الزحام من حقل Crowd prediction إذا توفر
                            crowdStatus:
                                eventData['Crowd prediction'] ?? 'Normal',
                            onSuggestRoute: () {
                              // يمكن استخدام Location_Address هنا لفتح الخرائط
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
