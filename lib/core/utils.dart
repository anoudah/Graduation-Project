import 'package:geolocator/geolocator.dart';

class AppUtils {
  /// Calculates the distance in meters between two GPS coordinates
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Formats the raw meters into a clean string for the UI (e.g., "850 m" or "2.4 km")
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      double kilometers = meters / 1000;
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }
}