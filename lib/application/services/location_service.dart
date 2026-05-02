import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// A centralized service to handle all native location and mapping functionalities.
/// This keeps your presentation layer (UI) clean by abstracting away the complex 
/// permission logic and platform-specific URI parsing.
class LocationService {
  
  /// Prompts the user for location permission and returns their exact GPS coordinates.
  /// Handles the complete flow: checking if hardware GPS is on, checking app permissions, 
  /// requesting permissions if needed, and finally fetching the high-accuracy location.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Hardware Check: Verify if the device's location services (GPS) are actually enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Return null if GPS is off. The UI should handle this gracefully 
      // (e.g., fallback to default coordinates like Riyadh city center).
      return null; 
    }

    // 2. Permission Check: See if the user has already granted the app permission.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If denied, explicitly request permission from the user via native dialog.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User denied the request again. We cannot proceed.
        return null; 
      }
    }
    
    // 3. Permanent Denial Check: Handle the case where the user checked "Don't ask again".
    if (permission == LocationPermission.deniedForever) {
      return null; 
    } 

    // 4. Fetch Location: All checks passed. Retrieve the current position.
    // Using LocationSettings ensures high accuracy and avoids deprecation warnings 
    // from older Geolocator versions.
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, // Uses more battery but vital for accurate map routing.
      ),
    );
  }

  /// Opens the native Google Maps application (or Apple Maps fallback) to provide driving directions.
  /// [destinationLat] and [destinationLng] are the exact coordinates of the AI-suggested event.
  static Future<void> openMapRoute(double destinationLat, double destinationLng) async {
    // This universal URL format works across both iOS and Android platforms.
    // The 'dir/?api=1&destination=' endpoint specifically triggers the turn-by-turn directions UI.
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng');
    
    // Check if the device has an app installed that can handle this URL natively.
    if (await canLaunchUrl(googleMapsUrl)) {
      // LaunchMode.externalApplication forces the OS to leave your app and open the dedicated Maps app.
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Throw an error so the calling UI block can catch it and show a SnackBar.
      throw 'Could not open maps.';
    }
  }
}