import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';
import 'compact_event_card.dart';


class HappeningNowSection extends StatelessWidget {
  final Future<List<dynamic>> trendingFuture;

  const HappeningNowSection({super.key, required this.trendingFuture});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Section title and a "See More" action button
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) => Text(context.loc.happeningNow, style: AppTextStyles.sectionTitle),
                  ),
                ),
                const SizedBox(width: 16),
                Builder(
                  builder: (context) => ElevatedButton.icon(
                    onPressed: () { 
       

                    }, // Action to see full trending list
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(context.loc.seeMore),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // FUTURE BUILDER: This ensures that while the trending events are loading, 
          // the rest of the Home Screen stays responsive and interactive.
          SizedBox(
            height: 250, 
            child: FutureBuilder<List<dynamic>>(
              future: trendingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Builder(
                    builder: (context) => Center(child: Text(context.loc.noEventsFound, style: const TextStyle(color: AppColors.textSecondary))),
                  );
                }
                
                final trendingEvents = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingEvents.length,
                  itemBuilder: (context, index) {
                    final eventData = Map<String, dynamic>.from(trendingEvents[index]);
                    return CompactEventCard(eventData: eventData);
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