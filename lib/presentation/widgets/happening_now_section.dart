import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';
import '../../application/providers/language_provider.dart';
import 'compact_event_card.dart';

class HappeningNowSection extends StatelessWidget {
  final Future<List<dynamic>> trendingFuture;

  const HappeningNowSection({super.key, required this.trendingFuture});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Section title only (See More removed for a cleaner look)
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) => Text(
                          context.loc.happeningNow, 
                          style: AppTextStyles.sectionTitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // FUTURE BUILDER: Keeps the Home Screen responsive while loading data
              SizedBox(
                height: 250, 
                child: FutureBuilder<List<dynamic>>(
                  future: trendingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Builder(
                        builder: (context) => Center(
                          child: Text(
                            context.loc.noEventsFound, 
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
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
      },
    );
  }
}