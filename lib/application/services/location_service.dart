import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  /// Prompts the user for permission and returns their exact GPS coordinates
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if the phone's GPS is turned on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; 
    }

    // 2. Check if the app has permission to use it
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; 
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null; 
    } 

    // 3. UPDATED: Using the new LocationSettings format to prevent deprecation warnings!
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Kicks the user to the native Google Maps / Apple Maps app for free driving directions
  static Future<void> openMapRoute(double destinationLat, double destinationLng) async {
    // This universal URL format works on both iOS and Android
    final Uri googleMapsUrl = Uri.parse('http://maps.apple.com/?daddr=$destinationLat,$destinationLng');
    
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open maps.';
    }
  }
}