import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../application/services/location_service.dart';
import '../widgets/event_card.dart';
import 'login_screen.dart';

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

  bool _checkLoginAndShowMessage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please login to interact with events"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "Login",
            textColor: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ),
      );
      return false; 
    }
    return true; 
  }

  Widget _buildTransitCard(Map<String, dynamic> stop) {
    final bool isFarewell = stop['title'].toString().toLowerCase().contains('farewell') || 
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
                  stop['title'] ?? 'Transit', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  stop['reasoning'] ?? 'Moving to next destination', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${stop['duration_minutes'] ?? 0} Mins", 
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
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
        title: const Text(
          "Your Smart Route",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
                    tourData['tour_title'] ?? "Your Custom Tour",
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 5),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Estimated time: ${tourData['total_estimated_hours']} hours",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      // TOTAL PRICE ROW
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actualTotal == 0 ? "Free Tour" : "Est. Cost: $totalPriceDisplay",
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
                              errorBuilder: (context, error, stackTrace) => const Text(
                                ' SAR', 
                                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
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

                    bool isTransit = stop['type'] == 'transit' || 
                                     stop['title'].toString().toLowerCase().contains('travel') || 
                                     stop['title'].toString().toLowerCase().contains('transit') ||
                                     stop['title'].toString().toLowerCase().contains('farewell');

                    // STOP PRICE PARSING
                    double currentPrice = _parsePrice(stop['price']);
                    
                    // Create the custom Widget for the individual EventCard
                    Widget priceWidget = currentPrice == 0 
                      ? const Text('Free', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentPrice.toInt().toString(),
                              style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/riyal_symbol.png',
                              height: 12,
                              color: AppColors.textMain,
                              errorBuilder: (context, error, stackTrace) => const Text(
                                ' SAR', 
                                style: TextStyle(color: AppColors.textMain, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );

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
                                        : AppColors.primary.withValues(alpha: 0.2),
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
                                ? _buildTransitCard(stop)
                                : EventCard(
                                    title: stop['title'] ?? 'Event',
                                    imagePath: stop['image'] ?? stop['Image'] ?? "https://placehold.co/400x300/png?text=Wasel+AI",
                                    description: stop['reasoning'] ?? 'AI Selected Path',
                                    schedule: "${stop['duration_minutes'] ?? 0} Mins",
                                    price: priceWidget, // Passing the WIDGET here instead of a string
                                    crowdStatus: stop['crowd_status'] ?? "MEDIUM",
                                    onLike: () async {
                                      if (_checkLoginAndShowMessage(context)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Event added to your favorites!"),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      }
                                    },
                                    onSuggestRoute: () async {
                                      final rawLat = stop['latitude'] ?? stop['lat'] ?? stop['Latitude'] ?? 
                                                     (stop['location'] != null ? stop['location']['lat'] : null) ??
                                                     (stop['coordinates'] != null ? stop['coordinates']['latitude'] : null);
                                                     
                                      final rawLng = stop['longitude'] ?? stop['lng'] ?? stop['Longitude'] ?? 
                                                     (stop['location'] != null ? stop['location']['lng'] : null) ??
                                                     (stop['coordinates'] != null ? stop['coordinates']['longitude'] : null);

                                      final double lat = double.tryParse(rawLat?.toString() ?? '0.0') ?? 0.0;
                                      final double lng = double.tryParse(rawLng?.toString() ?? '0.0') ?? 0.0;

                                      if (lat != 0.0 && lng != 0.0) {
                                        try {
                                          await LocationService.openMapRoute(lat, lng);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Could not open maps.')),
                                            );
                                          }
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Coordinates not available for this location.')),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Start Over',
                  style: TextStyle(
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