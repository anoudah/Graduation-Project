import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // جلب الـ ID الخاص بالمستخدم المسجل حالياً
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reminders'),
        backgroundColor: const Color(0xFF6B4B8A),
      ),
      // 1. نبدأ بـ StreamBuilder لمراقبة التذكيرات في جدول User_Interactions
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User_Interactions')
            .where('User_Id', isEqualTo: currentUserId) // فلترة المستخدم
            .where('Reminder', isEqualTo: true) // جلب التذكيرات فقط
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد تذكيرات حالياً'));
          }

          final reminderDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reminderDocs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final interaction =
                  reminderDocs[index].data() as Map<String, dynamic>;
              final String eventId = interaction['id'] ?? '';

              // 2. لكل تذكير، نستخدم FutureBuilder لجلب "اسم" الفعالية من جدول Events
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Events')
                    .doc(eventId)
                    .get(),
                builder: (context, eventSnapshot) {
                  if (!eventSnapshot.hasData) {
                    return const SizedBox(
                      height: 50,
                      child: Center(child: LinearProgressIndicator()),
                    );
                  }

                  final eventData =
                      eventSnapshot.data?.data() as Map<String, dynamic>?;

                  // الأسماء كما هي في الـ Firestore عندك (Title و Schedule)
                  final String title =
                      eventData?['Title'] ?? 'فعالية غير معروفة';
                  final String subtitle =
                      eventData?['Schedule'] ?? 'لم يتم تحديد وقت';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: Color(0xFF6B4B8A),
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(subtitle),
                      trailing: const Icon(
                        Icons.notifications,
                        color: Color(0xFF6B4B8A),
                      ),
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
