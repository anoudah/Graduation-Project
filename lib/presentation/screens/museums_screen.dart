import 'package:flutter/material.dart';
import '../widgets/event_card.dart'; // تأكدي من مسار ملف الـ widget

class MuseumsScreen extends StatelessWidget {
  const MuseumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة متاحف الرياض المحدثة
    final List<Map<String, dynamic>> riyadhMuseums = [
      {
        "title": "National Museum of Saudi Arabia",
        "image": "https://pnu.edu.sa/en/Announcements/PublishingImages/museum.jpg",
        "desc": "The official national museum of the Kingdom, located in the historical center of King Abdulaziz.",
        "time": "9:00 AM - 7:00 PM",
        "price": "Free",
        "status": "Low", // حالة الزحام المتوقعة من الـ AI
      },
      {
        "title": "Al Masmak Palace Museum",
        "image": "https://welcomesaudi.com/uploads/0000/1/2021/07/22/al-masmak-fort-riyadh.jpg",
        "desc": "A historical fortress built of clay and mud-brick that witnessed the rise of the modern Saudi state.",
        "time": "8:00 AM - 9:00 PM",
        "price": "Free",
        "status": "High",
      },
      {
        "title": "Saqr Al-Jazirah Aviation Museum",
        "image": "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/7d/95/92/the-museum-building.jpg",
        "desc": "Showcasing the aviation history of the Royal Saudi Air Force with real aircraft displays.",
        "time": "4:00 PM - 11:00 PM",
        "price": "20 SAR",
        "status": "Moderate",
      },
      {
        "title": "Historical Diriyah Museum",
        "image": "https://www.visitsaudi.com/content/dam/saudi-tourism/media/diriyah/at-turaif.jpg",
        "desc": "Located in Al-Turaif district, it tells the story of the First Saudi State.",
        "time": "10:00 AM - 12:00 AM",
        "price": "Check Tickets",
        "status": "High",
      },
      {
        "title": "Museum of Happiness",
        "image": "https://example.com/happiness_museum.jpg",
        "desc": "A creative space in Riyadh with interactive rooms and sensory experiences.",
        "time": "3:00 PM - 11:00 PM",
        "price": "120 SAR",
        "status": "Moderate",
      },
      {
        "title": "King Abdulaziz Historical Center",
        "image": "https://example.com/historical_center.jpg",
        "desc": "A huge complex featuring gardens and cultural galleries about the Kingdom's heritage.",
        "time": "8:00 AM - 8:00 PM",
        "price": "Free",
        "status": "Low",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // لون خلفية فاتح
      appBar: AppBar(
        title: const Text(
          "Museums in Riyadh",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E), // لون الهوية (كحلي)
        elevation: 2,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: riyadhMuseums.length,
        itemBuilder: (context, index) {
          final museum = riyadhMuseums[index];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: EventCard(
              title: museum['title'],
              imagePath: museum['image'],
              description: museum['desc'],
              schedule: museum['time'],
              price: museum['price'],
              crowdStatus: museum['status'],
              onSuggestRoute: () {
                // رسالة تفاعلية بسيطة عند الضغط
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Calculating the best route to ${museum['title']}..."),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}