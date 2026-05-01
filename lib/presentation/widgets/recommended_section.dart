import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';
import '../../application/providers/language_provider.dart';
import 'compact_event_card.dart';
import '../screens/recommended_full_screen.dart';

class RecommendedSection extends StatelessWidget {
  final Future<List<dynamic>> recommendedFuture;

  const RecommendedSection({super.key, required this.recommendedFuture});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
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
                    Expanded(
                      child: Text(context.loc.recommended, style: AppTextStyles.sectionTitle),
                    ),
                const SizedBox(width: 16),
                // تم التعديل هنا ليطابق شكل Near You
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: Title & See More Button (Fixed for Mobile) ---
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) => Text(
                      context.loc.recommended, 
                      style: AppTextStyles.sectionTitle,
                      maxLines: 1,           // Forces one line
                      softWrap: false,       // Prevents the "d" from dropping
                      overflow: TextOverflow.ellipsis, // Adds "..." if it's too tight
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Small gap between text and button
                Builder(
                  builder: (context) => ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendedFullScreen(recommendedFuture: recommendedFuture),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(
                      context.loc.seeMore,
                      style: const TextStyle(fontSize: 12), // Slightly smaller text for mobile
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: Size.zero, // Allows button to be as small as its content
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // --- CONTENT: The FutureBuilder ---
          SizedBox(
            height: 250, 
            child: FutureBuilder<List<dynamic>>(
              future: recommendedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } 
                else if (snapshot.hasError) {
                  return Builder(
                    builder: (context) => Center(
                      child: Text(context.loc.error, style: TextStyle(color: Colors.red.shade400))
                    ),
                  );
                } 
                else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Builder(
                    builder: (context) => Center(
                      child: Text(context.loc.noEventsFound, style: const TextStyle(color: AppColors.textSecondary))
                    ),
                  );
                }

                final recommendations = snapshot.data!;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final eventData = Map<String, dynamic>.from(recommendations[index]);
                    return CompactEventCard(
                      eventData: eventData,
                      isFullWidth: false, 
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}