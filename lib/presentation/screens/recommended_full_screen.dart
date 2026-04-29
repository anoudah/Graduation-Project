import 'package:flutter/material.dart';
import '../../core/theme.dart'; 
import '../widgets/compact_event_card.dart';

class RecommendedFullScreen extends StatelessWidget {
  final Future<List<dynamic>> recommendedFuture;

  const RecommendedFullScreen({super.key, required this.recommendedFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recommended', 
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // هنا التأكد من جلب البيانات وعرضها
      body: FutureBuilder<List<dynamic>>(
        future: recommendedFuture,
        builder: (context, snapshot) {
          // 1. حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } 
          
          // 2. حالة وجود خطأ
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          // 3. حالة عدم وجود بيانات
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recommendations found.', style: TextStyle(color: AppColors.textSecondary)));
          }

          // 4. النجاح في جلب البيانات
          final recommendations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              // تأكدي من تحويل البيانات لـ Map لضمان عدم حدوث خطأ في الـ Card
              final eventData = Map<String, dynamic>.from(recommendations[index]);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CompactEventCard(
                  eventData: eventData,
                  isFullWidth: true, // يخلي الكرت عريض وواضح
                ),
              );
            },
          );
        },
      ),
    );
  }
}