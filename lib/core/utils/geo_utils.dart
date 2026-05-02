import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AppUtils {
  
  /// Calculates the raw distance in meters between two GPS coordinates
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Formats meters into a localized distance string (e.g., "4.2 km" or "4.2 كم")
  static String formatDistance(double meters, BuildContext context) {
    bool isArabic = Directionality.of(context) == TextDirection.rtl;
    String unitKm = isArabic ? 'كم' : 'km';
    String unitM = isArabic ? 'م' : 'm';

    if (meters < 1000) {
      return '${meters.round()} $unitM';
    } else {
      double kilometers = meters / 1000;
      return '${kilometers.toStringAsFixed(1)} $unitKm';
    }
  }

  /// Calculates an estimated drive time (Riyadh context) and returns a localized string
  static String calculateDriveTime(double rawMeters, BuildContext context) {
    bool isArabic = Directionality.of(context) == TextDirection.rtl;
    
    // Riyadh traffic multiplier + assume 40km/h average city speed
    double actualDrivingDistanceMeters = rawMeters * 1.2;
    double distanceInKm = actualDrivingDistanceMeters / 1000;
    int timeInMinutes = (distanceInKm / 40 * 60).round();

    // Prevent displaying "0 min" for extremely close locations
    if (timeInMinutes < 1) timeInMinutes = 1;

    if (isArabic) {
      return 'حوالي $timeInMinutes دقيقة بالسيارة';
    } else {
      return '~$timeInMinutes min drive';
    }
  }
}