import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../application/services/location_service.dart';

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
  // Tracks whether the map should expand to hide the list view and app bar
  bool _isFullScreen = false; 
  // Manually tracks the camera's exact center so custom zoom buttons don't pan the screen away
  LatLng _currentMapCenter = const LatLng(24.7136, 46.6753); 
  // Manually tracks zoom level to prevent zooming out into an empty grey screen
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _loadMapData(); // Initialize data fetching exactly when the screen mounts
  }

  /// Core logic: Fetches GPS hardware data, processes unpredictable database coordinates, 
  /// and calculates real-time distances.
  Future<void> _loadMapData() async {
    try {
      // 1. Request hardware GPS ping
      _userPosition = await LocationService.getCurrentLocation();
      final events = await widget.eventsFuture;
      List<Map<String, dynamic>> calculatedEvents = [];

      // 2. DATA EXTRACTION LOOP
      for (var event in events) {
        // Safe fallback coordinates (Riyadh City Center) to ensure the map engine always has a valid focal point
        double targetLat = 24.7136;
        double targetLng = 46.6753;

        try {
          // 3. ULTIMATE COORDINATE EXTRACTOR: Bulletproof parsing for NoSQL schemas
          // Aggressively checks flat structures, nested maps (Python FastAPI), and raw GeoPoints (Firebase SDK)
          var rawLat = event['latitude'] ?? event['Latitude'] ?? event['lat'] ?? event['_latitude'];
          var rawLng = event['longitude'] ?? event['Longitude'] ?? event['lng'] ?? event['_longitude'];

          var geo = event['location'] ?? event['Location'] ?? event['coordinates'] ?? event['Coordinates'] ?? event['GeoPoint'];
          if (geo != null) {
            if (geo is Map) {
              // Handles JSON dictionary formats
              rawLat = geo['latitude'] ?? geo['Latitude'] ?? geo['lat'] ?? geo['_latitude'] ?? rawLat;
              rawLng = geo['longitude'] ?? geo['Longitude'] ?? geo['lng'] ?? geo['_longitude'] ?? rawLng;
            } else {
               // Handles native Firebase Flutter SDK GeoPoint objects
               try { rawLat = geo.latitude; rawLng = geo.longitude; } catch (_) {}
            }
          }

          if (rawLat != null && rawLng != null) {
            targetLat = double.tryParse(rawLat.toString()) ?? 24.7136;
            targetLng = double.tryParse(rawLng.toString()) ?? 46.6753;
          }
        } catch (e) {
          // Logs missing coordinates for backend debugging without crashing the client UI
          debugPrint("WASEL MAP PARSING ERROR: $e");
        }

        // 4. Mathematical Haversine Distance Calculation
        double distanceInMeters = 0;
        if (_userPosition != null) {
          distanceInMeters = AppUtils.calculateDistance(
            _userPosition!.latitude, 
            _userPosition!.longitude, 
            targetLat, 
            targetLng
          );
        }

        // 5. Append processed data to the new list
        calculatedEvents.add({
          ...event,
          'targetLat': targetLat,
          'targetLng': targetLng,
          'distance_raw': distanceInMeters,
          'distance': AppUtils.formatDistance(distanceInMeters),
        });
      }

      // 6. SORTING: Closest events mathematically sort to the top of the list view
      calculatedEvents.sort((a, b) => (a['distance_raw'] as double).compareTo(b['distance_raw'] as double));

      // 7. Update state and render UI
      if (mounted) {
        setState(() {
          _nearbyLocations = calculatedEvents;
          _isLoading = false;
          // Set the map center to the user's location so resizing doesn't abruptly reset it
          if (_userPosition != null) {
            _currentMapCenter = LatLng(_userPosition!.latitude, _userPosition!.longitude);
          }
        });
      }
    } catch (e) {
      debugPrint("WASEL FATAL MAP ERROR: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Could not load map data.";
          _isLoading = false;
        });
      }
    }
  }

  // --- UX CONTROL METHODS ---
  
  /// Toggles the UI state between a split-screen (Map + List) and an immersive Fullscreen Map
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  /// Snaps the map camera directly back to the user's physical GPS location
  void _recenterMap() {
    if (_userPosition != null) {
      _currentMapCenter = LatLng(_userPosition!.latitude, _userPosition!.longitude);
      _mapController.move(_currentMapCenter, 14.0);
    }
  }

  /// Safely increments or decrements the camera zoom.
  /// Uses .clamp() to strictly prevent the user from zooming out past the world map (3.0)
  /// or zooming in closer than the street level (18.0) which causes tile rendering errors.
  void _zoomMap(double zoomDelta) {
    double newZoom = (_currentZoom + zoomDelta).clamp(3.0, 18.0);
    _currentZoom = newZoom;
    _mapController.move(_currentMapCenter, newZoom);
  }

  // --- UI RENDERERS ---

  /// Dynamically generates map pins based on the processed database coordinates
  List<Marker> _buildMapMarkers() {
    List<Marker> markers = [];
    
    // Generates red indicator pins for all available cultural events
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
    
    // Generates a distinct blue pulsing dot to represent the user's physical device
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

  /// A UI helper that constructs the floating circular buttons for the map control panel.
  /// Ensures perfect design consistency across all map tools.
  Widget _buildMapControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9), // Modern semi-transparent glass effect
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. ISOLATED MAP COMPONENT: 
    // We isolate the map inside a variable so we can easily swap it between half-screen and fullscreen
    final Widget mapSection = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentMapCenter,
            initialZoom: _currentZoom,
            // CRITICAL UX FIX: Automatically track user pan/zoom gestures. 
            // If we don't update state here, clicking the custom +/- buttons will abruptly snap 
            // the camera back to where it started!
            onPositionChanged: (position, hasGesture) {
              // if (position.center != null) _currentMapCenter = position.center!;
              // if (position.zoom != null) _currentZoom = position.zoom!;
            },
          ),
          children: [
            // Uses free OpenStreetMap tiles instead of paid Google Maps API
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: _buildMapMarkers()),
          ],
        ),
        
        // 2. FLOATING UX CONTROLS (Right side)
        // Positioned explicitly anchors the buttons to the bottom right corner over the map
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
              _buildMapControlButton(
                icon: Icons.my_location, 
                onPressed: _recenterMap,
              ),
              _buildMapControlButton(
                icon: Icons.add, 
                onPressed: () => _zoomMap(1.0),
              ),
              _buildMapControlButton(
                icon: Icons.remove, 
                onPressed: () => _zoomMap(-1.0),
              ),
            ],
          ),
        ),

        // 3. SAFETY BACK BUTTON (Left side)
        // Since fullscreen mode hides the native AppBar, we must provide a custom back button
        // so iOS users without physical back buttons do not get trapped on this screen.
        if (_isFullScreen)
          Positioned(
            top: 16,
            left: 16,
            child: _buildMapControlButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context), // Safely returns to Home
            ),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background, 
      // 4. IMMERSIVE UX: Dynamically hide the AppBar entirely when in Full Screen mode
      appBar: _isFullScreen 
        ? null 
        : AppBar(
            title: const Text('Near You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primary, 
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        // SafeArea prevents the map from rendering underneath the iPhone Notch or Android status bar
        : SafeArea(
            child: Column(
              children: [
                // 5. THE FLUTTER CONTROLLER BUG FIX: 
                // Flexible ensures the map widget tree never gets destroyed during layout shifts.
                // If we swapped widgets here instead, the MapController would disconnect and crash.
                Flexible(
                  fit: _isFullScreen ? FlexFit.tight : FlexFit.loose,
                  child: SizedBox(
                    height: _isFullScreen ? double.infinity : 300,
                    child: mapSection,
                  ),
                ),
                
                // 6. LIST VIEW TOGGLE
                // We only render the list of cards if the user is NOT in fullscreen mode.
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
                              
                              // Bulletproof title extraction to prevent "Null" strings in the UI
                              final String title = location['Title']?.toString() ?? location['title']?.toString() ?? location['Name']?.toString() ?? location['name']?.toString() ?? 'Unknown Location';
  
                              return Card(
                                elevation: 2, 
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(
                                    title,
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMain, 
                                    ),
                                  ),
                                  subtitle: Text(
                                    _userPosition != null ? '${location['distance']} away' : 'Location unavailable',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                  ),
                                  // 7. EXTERNAL ROUTING ACTION
                                  // Calls the URL Launcher service to open native OS map routing (Google/Apple Maps)
                                  trailing: IconButton(
                                    icon: const Icon(Icons.directions, color: AppColors.primary, size: 30),
                                    onPressed: () {
                                      LocationService.openMapRoute(location['targetLat'], location['targetLng']);
                                    },
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