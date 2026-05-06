import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../screens/event_details_screen.dart'; 
import '../../core/localization/localization_extension.dart';
import '../../core/utils/bilingual_helper.dart';
import '../../application/services/location_service.dart';
import '../widgets/event_card.dart';

/// --- PRESENTATION & LOGIC LAYER ---
/// [SmartTourScreen] acts as the visual consumer for the AI-generated itinerary.
class SmartTourScreen extends StatelessWidget {
  final Map<String, dynamic> tourData;

  const SmartTourScreen({super.key, required this.tourData});

  /// Safely extracts a numeric double from various unpredictable AI price formats.
  double _parsePrice(dynamic rawPrice) {
    if (rawPrice == null) return 0.0;

    String priceString = '0';

    if (rawPrice is Map) {
      priceString = rawPrice['en']?.toString() ?? '0';
    } else {
      priceString = rawPrice.toString();
    }

    String numericOnly = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    
    int firstDot = numericOnly.indexOf('.');
    if (firstDot != -1) {
      numericOnly =
          numericOnly.substring(0, firstDot + 1) +
          numericOnly.substring(firstDot + 1).replaceAll('.', '');
    }
    return double.tryParse(numericOnly) ?? 0.0;
  }

  /// Builds a compact, distinct visual card representing the travel time between two events.
  Widget _buildTransitCard(BuildContext context, Map<String, dynamic> stop) {
    final bool isFarewell =
        stop['title'].toString().toLowerCase().contains('farewell') ||
        stop['title'].toString().toLowerCase().contains('end');

    bool isArabic = Directionality.of(context) == TextDirection.rtl;

    String title = BilingualHelper.getText(stop['title'], context);
    if (title.isEmpty) title = context.loc.transit;

    String reasoning = BilingualHelper.getText(stop['reasoning'], context);
    if (reasoning.isEmpty) reasoning = context.loc.movingToNextDestination;

    // =========================================================================
    // DYNAMIC BILINGUAL INTERCEPT LAYER (WEB SAFE)
    // Automatically translates AI strings using caseSensitive: false 
    // to prevent Chrome RegExp crashes.
    // =========================================================================
    if (isArabic) {
      title = title
          .replaceAll(RegExp(r'Drive to', caseSensitive: false), context.loc.aiDriveTo)
          .replaceAll(RegExp(r'Start at', caseSensitive: false), context.loc.aiStartAt)
          .replaceAll(RegExp(r'User Location', caseSensitive: false), context.loc.aiUserLocation)
          .replaceAll(RegExp(r'Back to Starting Point', caseSensitive: false), context.loc.aiBackToStartingPoint)
          .replaceAll(RegExp(r'Back to Riyadh City Hall', caseSensitive: false), context.loc.aiBackToCityHall)
          .replaceAll(RegExp(r'Transit', caseSensitive: false), context.loc.transit)
          // DB Fallbacks for Transit Cards
          .replaceAll(RegExp(r'National Museum of Saudi Arabia Tour', caseSensitive: false), 'المتحف الوطني السعودي')
          .replaceAll(RegExp(r'Al Masmak Palace Exhibition', caseSensitive: false), 'معرض قصر المصمك');

      reasoning = reasoning
          .replaceAll(RegExp(r'Starting point (for|of) the tour', caseSensitive: false), context.loc.aiStartingPointDesc)
          .replaceAll(RegExp(r'Approx\.?', caseSensitive: false), context.loc.aiApprox)
          .replaceAll(RegExp(r'min drive based on distance', caseSensitive: false), context.loc.aiMinDrive)
          .replaceAll(RegExp(r'Library transit', caseSensitive: false), context.loc.aiLibraryTransit);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isFarewell ? Icons.waving_hand : Icons.directions_car,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reasoning,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${stop['duration_minutes'] ?? 0} ${context.loc.minutes}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stops = tourData['stops'] as List<dynamic>? ?? [];
    bool isArabic = Directionality.of(context) == TextDirection.rtl;

    double actualTotal = 0;
    for (var stop in stops) {
      actualTotal += _parsePrice(stop['price']);
    }

    final String totalPriceDisplay = actualTotal == actualTotal.toInt()
        ? actualTotal.toInt().toString()
        : actualTotal.toStringAsFixed(2);

    // --- MAIN TITLE INTERCEPT ---
    String tourTitle = BilingualHelper.getText(tourData['tour_title'], context);
    if (tourTitle.isEmpty) tourTitle = context.loc.yourCustomTour;
    
    if (isArabic) {
      tourTitle = tourTitle
          .replaceAll(RegExp(r'Riyadh Cultural Museum Tour', caseSensitive: false), context.loc.aiMuseumTour)
          .replaceAll(RegExp(r'Riyadh Cultural Tour', caseSensitive: false), context.loc.aiRiyadhCulturalTour)
          .replaceAll(RegExp(r'Cultural Tour', caseSensitive: false), context.loc.aiCulturalTour);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          context.loc.yourSmartRoute,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // --- HEADER: TOUR TITLE ---
                      Text(
                        tourTitle,
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 5),

                      // --- HEADER: META DATA (TIME & COST) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${context.loc.estimatedTimeLabel}: ${tourData['total_estimated_hours']} ${context.loc.hours.toLowerCase()}",
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                actualTotal == 0
                                    ? context.loc.freeTour
                                    : "${context.loc.estCost}: $totalPriceDisplay",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (actualTotal > 0) ...[
                                const SizedBox(width: 4),
                                Image.asset(
                                  'assets/images/riyal_symbol.png',
                                  height: 12,
                                  color: AppColors.primary,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Text(
                                        ' SAR',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // =========================================================================
                      // TIMELINE RENDERING LOOP
                      // =========================================================================
                      ...stops.asMap().entries.map((entry) {
                        int index = entry.key;
                        var stop = entry.value;
                        bool isLast = index == stops.length - 1;

                        bool isTransit =
                            stop['type'] == 'transit' ||
                            stop['title'].toString().toLowerCase().contains('travel') ||
                            stop['title'].toString().toLowerCase().contains('transit') ||
                            stop['title'].toString().toLowerCase().contains('start at') ||
                            stop['title'].toString().toLowerCase().contains('farewell');

                        _parsePrice(stop['price']);

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // --- LEFT COLUMN: TIMELINE AXIS ---
                              SizedBox(
                                width: 60,
                                child: Column(
                                  children: [
                                    Text(
                                      stop['arrival_time'] ?? "--:--",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: isLast
                                            ? Colors.transparent
                                            : AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              // --- RIGHT COLUMN: EVENT/TRANSIT CARD ---
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  child: isTransit
                                      ? _buildTransitCard(context, stop)
                                      : (() {
                                          
                                          // Extract raw text
                                          String rawTitle = stop['Title'] ?? stop['title'] ?? stop['Name'] ?? 'Event';
                                          String rawAbout = stop['About'] ?? stop['about'] ?? stop['description'] ?? stop['desc'] ?? '';
                                          
                                          // DB HEURISTIC INTERCEPT: Translate known English DB events to Arabic
                                          if (isArabic) {
                                            rawTitle = rawTitle
                                              .replaceAll(RegExp(r'National Museum of Saudi Arabia Tour', caseSensitive: false), 'جولة المتحف الوطني السعودي')
                                              .replaceAll(RegExp(r'Al Masmak Palace Exhibition', caseSensitive: false), 'معرض قصر المصمك');
                                              
                                            rawAbout = rawAbout
                                              .replaceAll(RegExp(r'Explore eight interactive halls detailing the complete history of the Arabian Peninsula\.?', caseSensitive: false), 'استكشف ثماني قاعات تفاعلية تفصل التاريخ الكامل لشبه الجزيرة العربية.');
                                          }

                                          final Map<String, dynamic> formattedData = {
                                            ...stop,
                                            'Title': rawTitle,
                                            'About': rawAbout,
                                            'Image_Url': stop['Image_Url'] ?? stop['image_url'] ?? stop['image'] ?? '',
                                            'Price': stop['Price'] ?? stop['price'] ?? '0',
                                            'Category_ID': stop['Category_ID'] ?? stop['category'] ?? 'CONF',
                                            'id': stop['id'] ?? stop['ID'] ?? '',
                                          };

                                          return EventCard(
                                            eventData: formattedData,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EventDetailsScreen(
                                                    eventData: formattedData,
                                                  ),
                                                ),
                                              );
                                            },
                                            onSuggestRoute: () async {
                                              final rawLat = formattedData['latitude'] ?? formattedData['lat'] ?? formattedData['Latitude'];
                                              final rawLng = formattedData['longitude'] ?? formattedData['lng'] ?? formattedData['Longitude'];

                                              final double lat = double.tryParse(rawLat?.toString() ?? '0.0') ?? 0.0;
                                              final double lng = double.tryParse(rawLng?.toString() ?? '0.0') ?? 0.0;

                                              if (lat != 0.0 && lng != 0.0) {
                                                try {
                                                  await LocationService.openMapRoute(lat, lng);
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(context.loc.couldNotOpenMaps)),
                                                    );
                                                  }
                                                }
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(context.loc.coordinatesNotAvailable)),
                                                  );
                                                }
                                              }
                                            },
                                          );
                                        })(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // --- BOTTOM ACTION (Reset/Restart) ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.loc.startOver,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}