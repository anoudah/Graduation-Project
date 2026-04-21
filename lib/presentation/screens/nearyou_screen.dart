import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../application/services/location_service.dart';

/// A dedicated full-screen view for the Wasel app that plots the user's location 
/// and nearby cultural events on an interactive OpenStreetMap canvas.
class NearYouScreen extends StatefulWidget {
  final Future<List<dynamic>> eventsFuture;

  const NearYouScreen({super.key, required this.eventsFuture});

  @override
  State<NearYouScreen> createState() => _NearYouScreenState();
}

class _NearYouScreenState extends State<NearYouScreen> {
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

  Future<void> _loadMapData() async {
    try {
      _userPosition = await LocationService.getCurrentLocation();
      final events = await widget.eventsFuture;
      List<Map<String, dynamic>> calculatedEvents = [];

      for (var event in events) {
        double targetLat = 24.7136;
        double targetLng = 46.6753;

        try {
          // ULTIMATE COORDINATE EXTRACTOR
          var rawLat = event['latitude'] ?? event['Latitude'] ?? event['lat'] ?? event['_latitude'];
          var rawLng = event['longitude'] ?? event['Longitude'] ?? event['lng'] ?? event['_longitude'];

          var geo = event['location'] ?? event['Location'] ?? event['coordinates'] ?? event['Coordinates'] ?? event['GeoPoint'];
          if (geo != null) {
            if (geo is Map) {
              rawLat = geo['latitude'] ?? geo['Latitude'] ?? geo['lat'] ?? geo['_latitude'] ?? rawLat;
              rawLng = geo['longitude'] ?? geo['Longitude'] ?? geo['lng'] ?? geo['_longitude'] ?? rawLng;
            } else {
               try { rawLat = geo.latitude; rawLng = geo.longitude; } catch (_) {}
            }
          }

          if (rawLat != null && rawLng != null) {
            targetLat = double.tryParse(rawLat.toString()) ?? 24.7136;
            targetLng = double.tryParse(rawLng.toString()) ?? 46.6753;
          }
        } catch (e) {
          debugPrint("WASEL MAP PARSING ERROR: $e");
        }

        double distanceInMeters = 0;
        if (_userPosition != null) {
          distanceInMeters = AppUtils.calculateDistance(
            _userPosition!.latitude, 
            _userPosition!.longitude, 
            targetLat, 
            targetLng
          );
        }

        calculatedEvents.add({
          ...event,
          'targetLat': targetLat,
          'targetLng': targetLng,
          'distance_raw': distanceInMeters,
          'distance': AppUtils.formatDistance(distanceInMeters),
        });
      }

      calculatedEvents.sort((a, b) => (a['distance_raw'] as double).compareTo(b['distance_raw'] as double));

      if (mounted) {
        setState(() {
          _nearbyLocations = calculatedEvents;
          _isLoading = false;
          // Set the map center to the user's location so resizing doesn't reset it
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
        color: AppColors.white.withOpacity(0.9), 
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
    final Widget mapSection = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentMapCenter,
            initialZoom: _currentZoom,
            // Automatically track user pan/zoom so buttons don't desync
            onPositionChanged: (position, hasGesture) {
              if (position.center != null) _currentMapCenter = position.center!;
              if (position.zoom != null) _currentZoom = position.zoom!;
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: _buildMapMarkers()),
          ],
        ),
        
        // FLOATING UX CONTROLS (Right side)
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

        // SAFETY BACK BUTTON (Left side - only shows when AppBar is hidden)
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
      // 1. IMMERSIVE UX: Hide AppBar entirely when in Full Screen mode!
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
        // SafeArea prevents the map from hiding behind the iPhone Notch / Android status bar
        : SafeArea(
            child: Column(
              children: [
                // 2. THE FLUTTER BUG FIX: 
                // Flexible ensures the map widget tree never gets destroyed, keeping the controller active!
                Flexible(
                  fit: _isFullScreen ? FlexFit.tight : FlexFit.loose,
                  child: SizedBox(
                    height: _isFullScreen ? double.infinity : 300,
                    child: mapSection,
                  ),
                ),
                
                // LIST VIEW 
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