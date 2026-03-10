//Defines the properties of an Event (id, title, location, crowdLevel).
class Event {
  // Standard Database Fields
  final String id;
  final String title;
  final String category;
  final String? imageUrl;
  final String? locationAddress;
  final String? price;
  final double? rating;
  
  // The New AI Fields!
  final String? liveCrowdStatus;
  final int? liveCrowdScore;

  // 1. The Constructor
  Event({
    required this.id,
    required this.title,
    required this.category,
    this.imageUrl,
    this.locationAddress,
    this.price,
    this.rating,
    this.liveCrowdStatus,
    this.liveCrowdScore,
  });

  // 2. The JSON Translator (Factory Method)
  // This maps the exact exact Python keys (e.g., "Title") to our Dart variables (e.g., "title")
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      // We use ?? to provide a fallback just in case a field is missing in Firestore
      id: json['id'] ?? 'unknown_id',
      title: json['Title'] ?? 'Unknown Event',
      category: json['Category'] ?? 'Uncategorized',
      imageUrl: json['Image_Url'],
      locationAddress: json['Location_Address'],
      price: json['Price'],
      
      // Safely convert numbers
      rating: (json['Rating'] as num?)?.toDouble(),
      
      // AI Features mapped exactly to your Python output
      liveCrowdStatus: json['Live_Crowd_Status'],
      liveCrowdScore: json['Live_Crowd_Score'] != null 
          ? (json['Live_Crowd_Score'] as num).toInt() 
          : null,
    );
  }
}