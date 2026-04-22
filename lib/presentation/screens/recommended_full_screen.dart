import 'package:flutter/material.dart';
import '../../core/theme.dart'; 
import '../widgets/compact_event_card.dart';

class RecommendedFullScreen extends StatelessWidget {
  final Future<List<dynamic>> recommendedFuture;

  const RecommendedFullScreen({super.key, required this.recommendedFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام لون الخلفية الموحد من الثيم
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
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: recommendedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } 
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No recommendations found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final recommendations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final eventData = Map<String, dynamic>.from(recommendations[index]);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CompactEventCard(
                  eventData: eventData,
                  isFullWidth: true, // عشان ياخذ عرض الشاشة ويطلع مرتب
                ),
              );
            },
          );
        },
      ),
    );
  }
}