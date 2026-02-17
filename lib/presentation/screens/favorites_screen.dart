import 'package:flutter/material.dart';
import '../widgets/event_card.dart'; // تأكدي إن المسار لملف الكارد صح

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0), // نفس لون خلفية تطبيقكم
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6B4B8A), // اللون البنفسجي الموحد
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // هنا بنحط "بيانات وهمية" (Dummy Data) عشان دكتورة المادة تشوف الشكل
          // لما صديقتك تربط الباك إند، بتمسح هذي وتحط البيانات الحقيقية
          EventCard(
            title: "National Museum",
            imagePath: "https://pnu.edu.sa/en/Announcements/PublishingImages/museum.jpg",
            description: "Explore the rich history of Saudi Arabia.",
            schedule: "09:00 AM - 08:00 PM",
            price: "Free",
            crowdStatus: "Low",
            onSuggestRoute: () {},
          ),
          const SizedBox(height: 16),
          EventCard(
            title: "Al-Masmak Palace",
            imagePath: "https://www.visitsaudi.com/content/dam/saudi-tourism/media/riyadh/masmak.jpg",
            description: "A landmark fortress that tells the story of the kingdom.",
            schedule: "08:00 AM - 09:00 PM",
            price: "Free",
            crowdStatus: "Moderate",
            onSuggestRoute: () {},
          ),
        ],
      ),
    );
  }
}