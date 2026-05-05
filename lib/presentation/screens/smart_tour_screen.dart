import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../screens/event_details_screen.dart'; 
import '../../core/localization/localization_extension.dart';
import '../../core/utils/bilingual_helper.dart';
import '../../application/services/location_service.dart';
import '../widgets/event_card.dart';

/// --- PRESENTATION LAYER ---
/// [SmartTourScreen] is a pure consumer component that renders the final AI itinerary.
/// 
/// Responsibilities:
/// 1. Consumes the JSON dictionary provided by the Groq AI backend.
/// 2. Iterates through the stops to build a visually appealing vertical timeline.
/// 3. Defensively parses potentially messy AI data (like mixed currency strings).
/// 4. Maps the raw AI dictionary into the strict format required by [EventCard].
class SmartTourScreen extends StatelessWidget {
  final Map<String, dynamic> tourData;

  const SmartTourScreen({super.key, required this.tourData});

  /// Safely extracts a numeric double from various unpredictable AI price formats.
  /// 
  /// AI models often hallucinate currency formats. This method strips out all 
  /// non-numeric characters (like "SAR", "ريال", or "$") and safely handles 
  /// bilingual maps (e.g., {en: "10 SAR", ar: "١٠ ريال"}) to ensure the app doesn't crash.
  double _parsePrice(dynamic rawPrice) {
    if (rawPrice == null) return 0.0;

    String priceString = '0';

    if (rawPrice is Map) {
      // Prioritize English key for numeric extraction if it's a bilingual dictionary
      priceString = rawPrice['en']?.toString() ?? '0';
    } else {
      priceString = rawPrice.toString();
    }

    // Remove all non-numeric characters except the decimal point
    String numericOnly = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Ensure only one decimal point is present to prevent parsing errors
    int firstDot = numericOnly.indexOf('.');
    if (firstDot != -1) {
      numericOnly =
          numericOnly.substring(0, firstDot + 1) +
          numericOnly.substring(firstDot + 1).replaceAll('.', '');
    }
    return double.tryParse(numericOnly) ?? 0.0;
  }

  /// Builds a compact, distinct card for the "travel/transit" steps between events.
  Widget _buildTransitCard(BuildContext context, Map<String, dynamic> stop) {
    // Determine if this is the final trip home to change the icon
    final bool isFarewell =
        stop['title'].toString().toLowerCase().contains('farewell') ||
        stop['title'].toString().toLowerCase().contains('end');

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
                  BilingualHelper.getText(stop['title'], context).isNotEmpty
                      ? BilingualHelper.getText(stop['title'], context)
                      : context.loc.transit,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  BilingualHelper.getText(stop['reasoning'], context).isNotEmpty
                      ? BilingualHelper.getText(stop['reasoning'], context)
                      : context.loc.movingToNextDestination,
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
    // Safely extract the list of stops, defaulting to an empty list if the AI failed
    final stops = tourData['stops'] as List<dynamic>? ?? [];

    // =========================================================================
    // PRICE CALCULATION OVERRIDE
    // We ignore the AI's "total_price" because LLMs are bad at math.
    // Instead, we locally sum the prices of the actual stops to guarantee accuracy.
    // =========================================================================
    double actualTotal = 0;
    for (var stop in stops) {
      actualTotal += _parsePrice(stop['price']);
    }

    final String totalPriceDisplay = actualTotal == actualTotal.toInt()
        ? actualTotal.toInt().toString()
        : actualTotal.toStringAsFixed(2);

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
              // THE RESPONSIVE FIX: Center and Constrain the width for web/tablets!
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // --- HEADER: TOUR TITLE ---
                      Text(
                        BilingualHelper.getText(tourData['tour_title'], context).isNotEmpty
                            ? BilingualHelper.getText(tourData['tour_title'], context)
                            : context.loc.yourCustomTour,
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
                      // TIMELINE RENDERING
                      // Iterates through the stops to build the UI cards and the connecting lines.
                      // =========================================================================
                      ...stops.asMap().entries.map((entry) {
                        int index = entry.key;
                        var stop = entry.value;
                        bool isLast = index == stops.length - 1;

                        // Determine if the current node is a transit step or a real event
                        bool isTransit =
                            stop['type'] == 'transit' ||
                            stop['title'].toString().toLowerCase().contains('travel') ||
                            stop['title'].toString().toLowerCase().contains('transit') ||
                            stop['title'].toString().toLowerCase().contains('farewell');

                        // Pre-parse the price so it's ready for formatting
                        _parsePrice(stop['price']);

                        // IntrinsicHeight forces the Row children to match the height of the tallest child.
                        // This is essential for drawing the vertical connecting line properly.
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // --- TIMELINE AXIS (Time + Vertical Line) ---
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
                                        // Hide the line if it's the last item in the list
                                        color: isLast
                                            ? Colors.transparent
                                            : AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              // --- TIMELINE CONTENT (The Card) ---
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  child: isTransit
                                      ? _buildTransitCard(context, stop)
                                      : (() {
                                          // =========================================================
                                          // DATA NORMALIZATION (DEFENSIVE MAPPING)
                                          // The AI might return keys capitalized differently (e.g., 'Title' vs 'title').
                                          // We map everything to standard keys so [EventCard] doesn't crash or show blanks.
                                          // =========================================================
                                          final Map<String, dynamic> formattedData = {
                                            ...stop,
                                            'Title': stop['Title'] ?? stop['title'] ?? stop['Name'] ?? 'Event',
                                            // THE FIX: Included 'desc' so the AI's description maps to 'About'
                                            'About': stop['About'] ?? stop['about'] ?? stop['description'] ?? stop['desc'] ?? '',
                                            'Image_Url': stop['Image_Url'] ?? stop['image_url'] ?? stop['image'] ?? '',
                                            'Price': stop['Price'] ?? stop['price'] ?? '0',
                                            'Category_ID': stop['Category_ID'] ?? stop['category'] ?? 'CONF',
                                            'id': stop['id'] ?? stop['ID'] ?? '',
                                          };

                                          return EventCard(
                                            eventData: formattedData,

                                            // Navigate to details screen using the normalized data
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

                                            // Robust Map routing that handles string-to-double parsing natively
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
          
          // --- BOTTOM ACTION (Reset) ---
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