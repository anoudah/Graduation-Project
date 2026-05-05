import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../screens/event_details_screen.dart'; // أو المسار اللي فيه صفحة الديتلز عندك
import '../../core/localization/localization_extension.dart';
import '../../core/utils/bilingual_helper.dart';
import '../../application/services/location_service.dart';
import '../widgets/event_card.dart';

/// --- PRESENTATION LAYER ---
/// [SmartTourScreen] is a pure consumer component. It manages the dynamic rendering
/// of the itinerary, handling price normalization and defensive coordinate parsing.
class SmartTourScreen extends StatelessWidget {
  final Map<String, dynamic> tourData;

  const SmartTourScreen({super.key, required this.tourData});

  /// Helper to extract a double from various price formats (Map, String, or num).
  /// This specifically handles bilingual maps like {en: "10 SAR", ar: "١٠ ريال"}.
  double _parsePrice(dynamic rawPrice) {
    if (rawPrice == null) return 0.0;

    String priceString = '0';

    if (rawPrice is Map) {
      // Prioritize English key for numeric extraction
      priceString = rawPrice['en']?.toString() ?? '0';
    } else {
      priceString = rawPrice.toString();
    }

    // Remove all non-numeric characters except the decimal point
    final numericOnly = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numericOnly) ?? 0.0;
  }

  Widget _buildTransitCard(BuildContext context, Map<String, dynamic> stop) {
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
    final stops = tourData['stops'] as List<dynamic>? ?? [];

    // --- LOGIC: Calculate actual total locally to fix AI hallucinations ---
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BilingualHelper.getText(
                          tourData['tour_title'],
                          context,
                        ).isNotEmpty
                        ? BilingualHelper.getText(
                            tourData['tour_title'],
                            context,
                          )
                        : context.loc.yourCustomTour,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${context.loc.estimatedTimeLabel}: ${tourData['total_estimated_hours']} ${context.loc.hours.toLowerCase()}",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      // TOTAL PRICE ROW
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

                  ...stops.asMap().entries.map((entry) {
                    int index = entry.key;
                    var stop = entry.value;
                    bool isLast = index == stops.length - 1;

                    bool isTransit =
                        stop['type'] == 'transit' ||
                        stop['title'].toString().toLowerCase().contains(
                          'travel',
                        ) ||
                        stop['title'].toString().toLowerCase().contains(
                          'transit',
                        ) ||
                        stop['title'].toString().toLowerCase().contains(
                          'farewell',
                        );

                    // STOP PRICE PARSING
                    _parsePrice(stop['price']);

                    // Create the custom Widget for the individual EventCard

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                        : AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: isTransit
                                  ? _buildTransitCard(context, stop)
                                  : EventCard(
                                      // 1. تمرير البيانات كاملة كما هي مخزنة في stop
                                      eventData: stop,

                                      // 2. وظيفة الانتقال لصفحة الديتلز (هذا بديل لكل الأزرار المحذوفة)
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventDetailsScreen(
                                                  eventData:
                                                      stop, // تأكدي أن شاشة الديتلز تستقبل eventData
                                                ),
                                          ),
                                        );
                                      },

                                      // 3. كود الخريطة (نفس منطقك القديم لكن بطريقة أنظف)
                                      onSuggestRoute: () async {
                                        final rawLat =
                                            stop['latitude'] ??
                                            stop['lat'] ??
                                            stop['Latitude'] ??
                                            (stop['location'] != null
                                                ? stop['location']['lat']
                                                : null);
                                        final rawLng =
                                            stop['longitude'] ??
                                            stop['lng'] ??
                                            stop['Longitude'] ??
                                            (stop['location'] != null
                                                ? stop['location']['lng']
                                                : null);

                                        final double lat =
                                            double.tryParse(
                                              rawLat?.toString() ?? '0.0',
                                            ) ??
                                            0.0;
                                        final double lng =
                                            double.tryParse(
                                              rawLng?.toString() ?? '0.0',
                                            ) ??
                                            0.0;

                                        if (lat != 0.0 && lng != 0.0) {
                                          try {
                                            await LocationService.openMapRoute(
                                              lat,
                                              lng,
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    context
                                                        .loc
                                                        .couldNotOpenMaps,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                context
                                                    .loc
                                                    .coordinatesNotAvailable,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
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
