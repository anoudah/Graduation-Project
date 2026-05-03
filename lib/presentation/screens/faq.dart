import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// استدعاء ملف الثيم
import '../../core/theme.dart';
import '../../core/localization/app_localizations.dart'; 

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background, // تم استخدام الثيم
      appBar: AppBar(
        title: Text(
          localizations.faq,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary, // تم استخدام الثيم
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
            return Center(
              child: Text(localizations.noQuestionsAvailable),
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
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.primary, // تم استخدام الثيم
                      fontSize: 16,
                    ),
                  ),
                  iconColor: AppColors.primary, // تم استخدام الثيم
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        faqData['Answer'] ?? 'No Answer Available',
                        style: AppTextStyles.subtitle.copyWith(
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
