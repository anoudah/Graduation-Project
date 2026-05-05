import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import 'event_details_screen.dart'; 
import '../../data/datasources/ai_remote_source.dart';
import '../../core/theme.dart';
import '../../core/utils/bilingual_helper.dart';

// --- NEW IMPORTS FOR DYNAMIC DISTANCE ---
import 'package:geolocator/geolocator.dart';
import '../../core/utils/geo_utils.dart';

/// A screen that displays a localized, dynamic list of events for a specific category.
/// 
/// This screen connects to the Python AI backend to fetch real-time event data,
/// including crowd estimations. It handles asynchronous loading states, robust 
/// bilingual data extraction, and network image CORS fallbacks.
class CategoryScreen extends StatefulWidget {
  /// The localized display name of the category (e.g., "Museums", "المتاحف").
  final String categoryName;
  
  /// The unique identifier used to fetch data from the backend (e.g., "MUS").
  final String categoryId;
  
  /// The visual icon representing this category in the header.
  final IconData categoryIcon;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.categoryIcon,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  /// The service responsible for communicating with the AI backend.
  final AiRemoteSource _aiSource = AiRemoteSource();
  
  /// A future that holds the list of events fetched from the backend.
  late Future<List<dynamic>> _categoryEventsFuture;

  // --- NEW: Variable to hold the user's current GPS location ---
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    // Initialize the network request immediately when the screen loads.
    _categoryEventsFuture = _aiSource.fetchEventsByCategoryId(
      widget.categoryId,
    );
    // Fetch the user's location as soon as the screen opens
    _getUserLocation();
  }

  // --- NEW: Method to request permissions and get the user's coordinates ---
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      // Update the UI once the location is found
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      debugPrint("WASEL LOCATION ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determines if the screen is running on a compact mobile layout.
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(context),

            // Handles the asynchronous data fetching pipeline.
            FutureBuilder<List<dynamic>>(
              future: _categoryEventsFuture,
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  final localizations = AppLocalizations.of(context);
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(localizations.waselAICalculatingCrowds),
                        ],
                      ),
                    ),
                  );
                }

                // 2. Error State
                if (snapshot.hasError) {
                  final localizations = AppLocalizations.of(context);
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Text('${localizations.error}: ${snapshot.error}'),
                    ),
                  );
                }

                // 3. Success State
                final liveItems = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildCategoryHeader(context, isMobile, liveItems.length),
                    _buildCategoryItemsList(context, isMobile, liveItems),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Builds the custom navigation bar containing the back button, title, and action icons.
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textMain, 
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.categoryName,
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: 20,
              ), 
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textMain, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.textMain,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// Builds the large header section displaying the category icon and total item count.
  Widget _buildCategoryHeader(
    BuildContext context,
    bool isMobile,
    int totalItemCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight, 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.categoryIcon,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoryName,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalItemCount ${AppLocalizations.of(context).placesAvailable}',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Iterates through the fetched events and generates a responsive list of interactive cards.
  /// 
  /// This method actively protects against runtime crashes by routing all 
  /// JSON dictionary fields through the [BilingualHelper] and injecting safe 
  /// fallbacks for blocked or missing network images.
  Widget _buildCategoryItemsList(
    BuildContext context,
    bool isMobile,
    List<dynamic> categoryItems,
  ) {
    // Empty state fallback
    if (categoryItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          AppLocalizations.of(context).noEventsFoundForCategory,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: categoryItems.map((item) {
          
          debugPrint("CategoryScreen: categoryId=${widget.categoryId}");
          
          // Data Extraction: Safely parse localized bilingual maps.
          String title = BilingualHelper.getText(item['Title'], context);
          if (title.isEmpty) title = AppLocalizations.of(context).unknownEvent;

          String about = BilingualHelper.getText(item['About'] ?? item['Category'], context);

          // Asset Extraction: Fallback for empty or CORS-blocked images.
          String imageUrl = BilingualHelper.getText(item['Image_Url'] ?? item['Image'], context);
          if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
            imageUrl = 'https://placehold.co/120x120/png?text=No+Image'; 
          }

          // Dynamic styling based on AI crowd estimation.
          String crowdStatus = item['Live_Crowd_Status'] ?? "LOW";
          Color crowdColor = Colors.green;
          if (crowdStatus == "MEDIUM") crowdColor = Colors.orange;
          if (crowdStatus == "HIGH") crowdColor = Colors.red;

          // --- CLEAN, DYNAMIC DISTANCE CALCULATION ---
          String distanceText = Directionality.of(context) == TextDirection.rtl ? '-- كم' : '-- km';
          
          if (_userPosition != null) {
            try {
              double eventLat = 24.7136; 
              double eventLng = 46.6753;

              var rawLat = item['latitude'] ?? item['Latitude'] ?? item['lat'] ?? item['_latitude'];
              var rawLng = item['longitude'] ?? item['Longitude'] ?? item['lng'] ?? item['_longitude'];

              var geo = item['location'] ?? item['Location'] ?? item['coordinates'] ?? item['Coordinates'];
              if (geo != null) {
                if (geo is Map) {
                  // If Python sent it as a JSON Dictionary
                  rawLat = geo['latitude'] ?? geo['Latitude'] ?? geo['lat'] ?? geo['_latitude'] ?? rawLat;
                  rawLng = geo['longitude'] ?? geo['Longitude'] ?? geo['lng'] ?? geo['_longitude'] ?? rawLng;
                } else {
                  // If it actually is a native Firebase GeoPoint
                  try {
                    rawLat = geo.latitude;
                    rawLng = geo.longitude;
                  } catch (_) {}
                }
              }

              if (rawLat != null && rawLng != null) {
                eventLat = double.tryParse(rawLat.toString()) ?? 24.7136;
                eventLng = double.tryParse(rawLng.toString()) ?? 46.6753;
              }

              // 1. Calculate using your AppUtils!
              double distanceInMeters = AppUtils.calculateDistance(
                _userPosition!.latitude,
                _userPosition!.longitude,
                eventLat,
                eventLng,
              );

              // 2. Format using your AppUtils!
              distanceText = AppUtils.formatDistance(distanceInMeters, context);

            } catch (e) {
              debugPrint("Error calculating distance: $e");
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Navigate to deep view, passing the specific event map forward.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(
                      eventData: item as Map<String, dynamic>,
                      sourceCategoryId: widget.categoryId,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  // Event Thumbnail
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.avatarBg,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.image_not_supported,
                          color: AppColors.iconGrey,
                        ),
                      ),
                    ),
                  ),

                  // Event Details Block
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title, 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            about, 
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Footer row containing distance and crowd status
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              
                              // --- UPDATED: Distance is now fully dynamic and bilingual! ---
                              Text(
                                distanceText, 
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: crowdColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  crowdStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: crowdColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // End Indicator
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
