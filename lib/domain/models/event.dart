import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String title;
  final String about;
  final String category;
  final String categoryId;
  final String crowdPrediction;
  final String bookingUrl;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final String phone;
  final String price;
  final double rating;
  final String schedule;
  final List<String> tags; // مصفوفة الاهتمامات للـ AI
  final DateTime startTime; // وقت البداية للزحام
  final DateTime endTime; // وقت النهاية للزحام

  EventModel({
    required this.title,
    required this.about,
    required this.category,
    required this.categoryId,
    required this.crowdPrediction,
    required this.bookingUrl,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.phone,
    required this.price,
    required this.rating,
    required this.schedule,
    required this.tags,
    required this.startTime,
    required this.endTime,
  });

  // المترجم: يحول الخريطة (Map) القادمة من الفايربيس إلى كائن (Object) في دارت
  factory EventModel.fromFirestore(Map<String, dynamic> data) {
    return EventModel(
      title: data['Title'] ?? '', // ملاحظة الـ T الكبيرة
      about: data['About'] ?? '',
      category: data['Category'] ?? '',
      categoryId: data['Category_ID'] ?? '',
      crowdPrediction: data['Crowd_Prediction'] ?? 'LOW',
      bookingUrl: data['Booking_Url'] ?? '',
      imageUrl: data['Image_Url'] ?? '',
      latitude: (data['Latitude'] as num).toDouble(),
      longitude: (data['Longitude'] as num).toDouble(),
      locationAddress: data['Location_Address'] ?? '',
      phone: data['Phone'] ?? '',
      price: data['Price'] ?? '',
      rating: (data['Rating'] as num).toDouble(),
      schedule: data['Schedule'] ?? '',
      // التعامل مع المصفوفة (Array)
      tags: List<String>.from(data['tags'] ?? []),
      // التعامل مع الوقت (Timestamp)
      startTime: (data['start_time'] as Timestamp).toDate(),
      endTime: (data['end_time'] as Timestamp).toDate(),
    );
  }
}
