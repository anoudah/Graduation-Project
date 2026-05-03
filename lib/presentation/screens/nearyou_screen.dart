import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../application/services/location_service.dart';
import '../../core/localization/app_localizations.dart';
import 'event_details_screen.dart';

// --- NEW IMPORTS FOR ARCHITECTURE FIX ---
import '../../core/utils/geo_utils.dart';
import '../../core/utils/bilingual_helper.dart';

/// A dedicated full-screen view for the Wasel app that plots the user's location
/// and nearby cultural events on an interactive OpenStreetMap canvas.
/// Features dynamic UX controls including immersive fullscreen toggling, custom zoom, and recentering.
class NearYouScreen extends StatefulWidget {
  // Receives the data promise from the Home Screen to prevent redundant network calls to the backend
  final Future<List<dynamic>> eventsFuture;

  const NearYouScreen({super.key, required this.eventsFuture});

  @override
  State<NearYouScreen> createState() => _NearYouScreenState();
}

class _NearYouScreenState extends State<NearYouScreen> {
  // Controller to programmatically pan and zoom the map camera
  final MapController _mapController = MapController();

  List<Map<String, dynamic>> _nearbyLocations = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _userPosition;

  // --- MAP STATE MANAGEMENT ---
  bool _isFullScreen = false;
  LatLng _currentMapCenter = const LatLng(24.7136, 46.6753);
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _loadMapData(); 
  }

  /// Core logic: Fetches GPS hardware data, processes unpredictable database coordinates,
  /// and calculates real-time distances using the unified AppUtils.
  Future<void> _loadMapData() async {
    try {
      // 1. Request hardware GPS ping
      _userPosition = await LocationService.getCurrentLocation();
      final events = await widget.eventsFuture;
      List<Map<String, dynamic>> calculatedEvents = [];

      // 2. DATA EXTRACTION LOOP
      for (var event in events) {
        double targetLat = 24.7136;
        double targetLng = 46.6753;

        try {
          // 3. ULTIMATE COORDINATE EXTRACTOR
          var rawLat = event['latitude'] ?? event['Latitude'] ?? event['lat'] ?? event['_latitude'];
          var rawLng = event['longitude'] ?? event['Longitude'] ?? event['lng'] ?? event['_longitude'];

          var geo = event['location'] ?? event['Location'] ?? event['coordinates'] ?? event['Coordinates'] ?? event['GeoPoint'];
          if (geo != null) {
            if (geo is Map) {
              rawLat = geo['latitude'] ?? geo['Latitude'] ?? geo['lat'] ?? geo['_latitude'] ?? rawLat;
              rawLng = geo['longitude'] ?? geo['Longitude'] ?? geo['lng'] ?? geo['_longitude'] ?? rawLng;
            } else {
              try {
                rawLat = geo.latitude;
                rawLng = geo.longitude;
              } catch (_) {}
            }
          }

          if (rawLat != null && rawLng != null) {
            targetLat = double.tryParse(rawLat.toString()) ?? 24.7136;
            targetLng = double.tryParse(rawLng.toString()) ?? 46.6753;
          }
        } catch (e) {
          debugPrint("WASEL MAP PARSING ERROR: $e");
        }

        // 4. MATHEMATICAL HAVERSINE DISTANCE & TIME (Using AppUtils!)
        double distanceInMeters = 0;
        String timeString = 'Unknown time';
        String distanceString = '---';

        if (_userPosition != null) {
          distanceInMeters = AppUtils.calculateDistance(
            _userPosition!.latitude,
            _userPosition!.longitude,
            targetLat,
            targetLng,
          );

          // Use the Utility to get bilingual strings safely
          if (mounted) {
            distanceString = AppUtils.formatDistance(distanceInMeters, context);
            timeString = AppUtils.calculateDriveTime(distanceInMeters, context);
          }
        }

        // 5. Append processed data to the new list
        calculatedEvents.add({
          ...event,
          'targetLat': targetLat,
          'targetLng': targetLng,
          'distance_raw': distanceInMeters,
          'distance': distanceString, 
          'time': timeString, 
        });
      }

      // 6. SORTING: Closest events mathematically sort to the top
      calculatedEvents.sort(
        (a, b) => (a['distance_raw'] as double).compareTo(b['distance_raw'] as double),
      );

      // 7. Update state and render UI
      if (mounted) {
        setState(() {
          _nearbyLocations = calculatedEvents;
          _isLoading = false;
          if (_userPosition != null) {
            _currentMapCenter = LatLng(_userPosition!.latitude, _userPosition!.longitude);
          }
        });
      }
    } catch (e) {
      debugPrint("WASEL FATAL MAP ERROR: $e");
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        setState(() {
          _errorMessage = localizations.couldNotLoadMapData;
          _isLoading = false;
        });
      }
    }
  }

  // --- UX CONTROL METHODS ---

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _recenterMap() {
    if (_userPosition != null) {
      _currentMapCenter = LatLng(_userPosition!.latitude, _userPosition!.longitude);
      _mapController.move(_currentMapCenter, 14.0);
    }
  }

  void _zoomMap(double zoomDelta) {
    double newZoom = (_currentZoom + zoomDelta).clamp(3.0, 18.0);
    _currentZoom = newZoom;
    _mapController.move(_currentMapCenter, newZoom);
  }

  // --- UI RENDERERS ---

  List<Marker> _buildMapMarkers() {
    List<Marker> markers = [];

    for (var location in _nearbyLocations) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(location['targetLat'], location['targetLng']),
          child: const Icon(Icons.location_on, color: AppColors.primary, size: 35),
        ),
      );
    }

    if (_userPosition != null) {
      markers.add(
        Marker(
          width: 20,
          height: 20,
          point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildMapControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9), 
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: IconButton(icon: Icon(icon, color: AppColors.primary), onPressed: onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // 1. ISOLATED MAP COMPONENT
    final Widget mapSection = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentMapCenter,
            initialZoom: _currentZoom,
            onPositionChanged: (position, hasGesture) {},
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.wasel.riyadh_app',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: _buildMapMarkers()),
          ],
        ),

        // 2. FLOATING UX CONTROLS
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMapControlButton(
                icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                onPressed: _toggleFullScreen,
              ),
              _buildMapControlButton(icon: Icons.my_location, onPressed: _recenterMap),
              _buildMapControlButton(icon: Icons.add, onPressed: () => _zoomMap(1.0)),
              _buildMapControlButton(icon: Icons.remove, onPressed: () => _zoomMap(-1.0)),
            ],
          ),
        ),

        // 3. SAFETY BACK BUTTON
        if (_isFullScreen)
          Positioned(
            top: 16,
            left: 16,
            child: _buildMapControlButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context), 
            ),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                localizations.nearYou,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primary,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: Column(
                children: [
                  Flexible(
                    fit: _isFullScreen ? FlexFit.tight : FlexFit.loose,
                    child: SizedBox(
                      height: _isFullScreen ? double.infinity : 300,
                      child: mapSection,
                    ),
                  ),

                  if (!_isFullScreen)
                    Expanded(
                      child: _errorMessage != null
                          ? Center(child: Text(_errorMessage!))
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListView.builder(
                                itemCount: _nearbyLocations.length,
                                itemBuilder: (context, index) {
                                  final location = _nearbyLocations[index];

                                  // --- THE BILINGUAL FIX: Safely unpack the title map! ---
                                  String title = BilingualHelper.getText(
                                    location['Title'] ?? location['Name'], 
                                    context
                                  );
                                  if (title.isEmpty) title = localizations.unknownLocation;

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventDetailsScreen(eventData: location),
                                          ),
                                        );
                                      },

                                      title: Text(
                                        title, // Safe Bilingual Title!
                                        style: AppTextStyles.subtitle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                      subtitle: _userPosition != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 6.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${location['distance']}', // Safe Bilingual Distance!
                                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${location['time']}', // Safe Bilingual Time!
                                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Text(
                                              localizations.locationUnavailable,
                                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                            ),

                                      trailing: GestureDetector(
                                        onTap: () {
                                          LocationService.openMapRoute(
                                            location['targetLat'],
                                            location['targetLng'],
                                          );
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.directions, color: AppColors.primary, size: 24),
                                            Text(
                                              localizations.navigate,
                                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                ],
              ),
            ),
    );
  }
}
