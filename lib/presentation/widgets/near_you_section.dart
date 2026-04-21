import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../application/services/location_service.dart';
import '../screens/nearyou_screen.dart'; 
import 'near_you_card.dart';

/// A dynamic widget that calculates the distance between the user's physical
/// device and a list of cultural events, displaying the 5 closest locations.
class NearYouSection extends StatefulWidget {
  // Accepts a Future list of events from the parent Home Screen to prevent redundant network calls.
  final Future<List<dynamic>> eventsFuture;

  const NearYouSection({super.key, required this.eventsFuture});

  @override
  State<NearYouSection> createState() => _NearYouSectionState();
}

class _NearYouSectionState extends State<NearYouSection> {
  // Holds the sorted list of events merged with their calculated distances
  List<Map<String, dynamic>> _nearbyLocations = [];
  
  // Controls the loading spinner while waiting for GPS and database queries
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Begin calculating distances immediately when the widget enters the screen
    _calculateNearbyEvents();
  }

  /// Core mathematical and data-parsing function
  Future<void> _calculateNearbyEvents() async {
    try {
      // 1. HARDWARE PING: Ask the device for exact GPS coordinates
      final position = await LocationService.getCurrentLocation();
      
      // Handle the case where the user denies GPS permissions
      if (position == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "Location permission denied.";
            _isLoading = false;
          });
        }
        return;
      }

      // 2. DATABASE READ: Wait for the events to finish downloading
      final events = await widget.eventsFuture;
      List<Map<String, dynamic>> calculatedEvents = [];

      // 3. THE MATH LOOP & DATA PARSING
      for (var event in events) {
        // Fallback coordinates (Riyadh City Center) to prevent fatal app crashes
        double targetLat = 24.7136; 
        double targetLng = 46.6753;

        try {
          // ULTIMATE COORDINATE EXTRACTOR: 
          // NoSQL schemas can be unpredictable. This aggressively searches the event 
          // object for any known spelling of latitude/longitude.
          
          // A. Check if coordinates are flat on the root object
          var rawLat = event['latitude'] ?? event['Latitude'] ?? event['lat'] ?? event['_latitude'];
          var rawLng = event['longitude'] ?? event['Longitude'] ?? event['lng'] ?? event['_longitude'];

          // B. Check if coordinates are nested inside a location or GeoPoint object
          var geo = event['location'] ?? event['Location'] ?? event['coordinates'] ?? event['Coordinates'] ?? event['GeoPoint'];
          if (geo != null) {
            if (geo is Map) {
              // Handles JSON dictionary formats (e.g., from Python FastAPI)
              rawLat = geo['latitude'] ?? geo['Latitude'] ?? geo['lat'] ?? geo['_latitude'] ?? rawLat;
              rawLng = geo['longitude'] ?? geo['Longitude'] ?? geo['lng'] ?? geo['_longitude'] ?? rawLng;
            } else {
               // Handles native Firebase Flutter SDK GeoPoint objects
               try { rawLat = geo.latitude; rawLng = geo.longitude; } catch (_) {}
            }
          }

          // C. Parse the discovered values into usable mathematical doubles
          if (rawLat != null && rawLng != null) {
            targetLat = double.tryParse(rawLat.toString()) ?? 24.7136;
            targetLng = double.tryParse(rawLng.toString()) ?? 46.6753;
          } else {
            // Logs missing coordinates to the console for backend debugging
            debugPrint("WASEL DEBUG: Missing coordinates for event. Available keys: ${event.keys}");
          }
        } catch (e) {
          debugPrint("WASEL DEBUG: Parsing error: $e");
        }

        // 4. HA-VERSINE FORMULA: Calculate physical distance in meters
        double distanceInMeters = AppUtils.calculateDistance(
          position.latitude, 
          position.longitude, 
          targetLat, 
          targetLng
        );

        // 5. MERGE DATA: Combine original event data with the new distance math
        calculatedEvents.add({
          ...event, 
          'distance_raw': distanceInMeters, // Kept as a double for accurate sorting
          'distance': AppUtils.formatDistance(distanceInMeters), // Formatted string for UI (e.g., "2.4 km")
        });
      }

      // 6. SORTING: Order the list from closest to farthest
      calculatedEvents.sort((a, b) => (a['distance_raw'] as double).compareTo(b['distance_raw'] as double));

      // 7. UI UPDATE: Redraw the widget with the top 5 closest locations
      if (mounted) {
        setState(() {
          _nearbyLocations = calculatedEvents.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Could not calculate distances.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & NAVIGATION ---
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: Text('Near you', style: AppTextStyles.sectionTitle)),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      // Pass the same data future to the map screen for optimal performance
                      builder: (context) => NearYouScreen(eventsFuture: widget.eventsFuture),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('See more'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // --- HORIZONTAL LIST CONTENT ---
          SizedBox(
            height: 124, 
            child: _buildContent(), // Delegates rendering based on loading/error/success state
          ),
        ],
      ),
    );
  }

  /// State-driven UI renderer
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary)));
    }
    if (_nearbyLocations.isEmpty) {
      return const Center(child: Text("No locations found nearby.", style: TextStyle(color: AppColors.textSecondary)));
    }

    // Success State: Render the scrollable cards
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _nearbyLocations.length,
      itemBuilder: (context, index) {
        return NearYouCard(locationData: _nearbyLocations[index]);
      },
    );
  }
}