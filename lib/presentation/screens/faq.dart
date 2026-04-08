import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0),
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6B4B8A),
        centerTitle: true,
        elevation: 0,
      ),
      // استخدام StreamBuilder لجلب البيانات بشكل حي من الفايربيس
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('FAQs')
            .orderBy('Order') // ترتيب الأسئلة حسب رقم Order
            .snapshots(),
        builder: (context, snapshot) {
          // حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // في حال عدم وجود بيانات
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No questions available at the moment."),
            );
          }

          // عرض الأسئلة في قائمة
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var faqData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  shape: const Border(), // لإزالة الحدود الافتراضية عند الفتح
                  title: Text(
                    faqData['Question'] ?? 'No Question Found',
                    style: const TextStyle(
                      color: Color(0xFF6B4B8A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: const Color(0xFF6B4B8A),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        faqData['Answer'] ?? 'No Answer Available',
                        style: const TextStyle(
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
