import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  // 1. Standard Database Fields
  final String id;
  final String title;
  final String about;
  final String category;
  final String categoryId;
  final String bookingUrl;
  final String imageUrl;
  final String locationAddress;
  final String phone;
  final String price;
  final double rating;
  final String schedule;
  final List<String> tags;
  final DateTime startTime;
  final DateTime endTime;
  final int venueCapacity; 

  // 2. The AI Fields!
  final String? liveCrowdStatus;
  final int? liveCrowdScore;

  // Constructor
  EventModel({
    required this.id,
    required this.title,
    required this.about,
    required this.category,
    required this.categoryId,
    required this.bookingUrl,
    required this.imageUrl,
    required this.locationAddress,
    required this.phone,
    required this.price,
    required this.rating,
    required this.schedule,
    required this.tags,
    required this.startTime,
    required this.endTime,
    required this.venueCapacity,
    this.liveCrowdStatus,
    this.liveCrowdScore,
  });

  // Factory Method for Firestore
  factory EventModel.fromFirestore(Map<String, dynamic> data) {
    return EventModel(
      // ID from the first version
      id: data['id'] ?? 'unknown_id',
      
      // Standard fields with safety fallbacks
      title: data['Title'] ?? '',
      about: data['About'] ?? '',
      category: data['Category'] ?? '',
      categoryId: data['Category_ID'] ?? '',
      bookingUrl: data['Booking_Url'] ?? '',
      imageUrl: data['Image_Url'] ?? '',
      locationAddress: data['Location_Address'] ?? '',
      phone: data['Phone'] ?? '',
      price: data['Price'] ?? '',
      rating: (data['Rating'] ?? 0).toDouble(),
      schedule: data['Schedule'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      
      // Time conversions
      startTime: (data['start_time'] as Timestamp? ?? Timestamp.now()).toDate(),
      endTime: (data['end_time'] as Timestamp? ?? Timestamp.now()).toDate(),
      venueCapacity: data['venue_capacity'] ?? 0,

      // AI Features mapped exactly to the Python output
      liveCrowdStatus: data['Live_Crowd_Status'],
      liveCrowdScore: data['Live_Crowd_Score'] != null 
          ? (data['Live_Crowd_Score'] as num).toInt() 
          : null,
    );
  }
}