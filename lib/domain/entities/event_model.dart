class EventModel {
  final String id;
  final String title;
  final String about;
  final String imageUrl;

  final String schedule;
  final String price;
  final String crowdPrediction;
  final String phoneNumber;
  final String location;

  final bool isAttending;
  final int commentsCount;

  const EventModel({
    required this.id,
    required this.title,
    required this.about,
    required this.imageUrl,
    required this.schedule,
    required this.price,
    required this.crowdPrediction,
    required this.phoneNumber,
    required this.location,
    required this.isAttending,
    required this.commentsCount,
  });

  factory EventModel.fromFirestore(String id, Map<String, dynamic> data) {
    return EventModel(
      id: id,
      title: (data['title'] ?? '').toString(),
      about: (data['about'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      schedule: (data['schedule'] ?? '').toString(),
      price: (data['price'] ?? '').toString(),
      crowdPrediction: (data['crowdPrediction'] ?? '').toString(),
      phoneNumber: (data['phoneNumber'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      isAttending: (data['isAttending'] ?? false) as bool,
      commentsCount: ((data['commentsCount'] ?? 0) as num).toInt(),
    );
  }
}
