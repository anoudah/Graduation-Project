import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'compact_event_card.dart';
import '../screens/recommended_full_screen.dart';

class RecommendedSection extends StatelessWidget {
  // Pass the Future from the Home Screen into this widget
  final Future<List<dynamic>> recommendedFuture;

  const RecommendedSection({super.key, required this.recommendedFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: Title & See More Button ---
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Recommended', style: AppTextStyles.sectionTitle),
                ),
                const SizedBox(width: 16),
                // تم التعديل هنا ليطابق شكل Near You
                ElevatedButton.icon(
                  onPressed: () {
                   Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecommendedFullScreen(recommendedFuture: recommendedFuture),
    ),
  );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('See more'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // --- CONTENT: The FutureBuilder ---
          SizedBox(
            height: 250, // Matches your CompactEventCard height
            child: FutureBuilder<List<dynamic>>(
              future: recommendedFuture,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } 
                // 2. Error State
                else if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load recommendations.', style: TextStyle(color: Colors.red.shade400))
                  );
                } 
                // 3. Empty State
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No recommendations available right now.', style: TextStyle(color: AppColors.textSecondary))
                  );
                }

                // 4. Success State!
                final recommendations = snapshot.data!;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final eventData = Map<String, dynamic>.from(recommendations[index]);
                    return CompactEventCard(
                      eventData: eventData,
                      isFullWidth: false, // Ensures it stays compact for the horizontal scroll
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}