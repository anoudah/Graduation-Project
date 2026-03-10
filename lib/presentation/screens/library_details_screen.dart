import 'package:flutter/material.dart';
import 'RouteSuggestionScreen.dart';

class LibraryDetailsScreen extends StatefulWidget {
  const LibraryDetailsScreen({super.key});

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  // متغير لحفظ حالة القلب (مفضل أو لا)
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildTopNav(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildImageSection()),
                  const SizedBox(width: 40),
                  Expanded(flex: 1, child: _buildInfoSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // قسم الصورة مع زر القلب التفاعلي
  Widget _buildImageSection() {
    return Column(
      children: [
        const Text(
          "King Fahad National Library",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            'https://lh3.googleusercontent.com/p/AF1QipN9u-VpW7jGz7Zz', // رابط تجريبي
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 350, color: Colors.grey[300], child: const Icon(Icons.library_books, size: 100),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            // زر القلب التفاعلي هنا
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite; // يغير الحالة عند الضغط
                });
              },
            ),
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("I'm attending", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  // باقي الدوال (Search, Nav, Info) تظلين تستخدمينها كما هي في الكود السابق
  Widget _buildTopNav() {
    return const Text("Libraries", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold));
  }

  Widget _buildSearchBar() {
    return Container(
      width: 500,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(30)),
      child: const TextField(decoration: InputDecoration(hintText: "search", border: InputBorder.none, icon: Icon(Icons.search))),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("About", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const Text("Detailed info about King Fahad Library..."),
        const SizedBox(height: 20),
        const Text("Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        _buildDetailRow("Schedule:", "8 AM - 8 PM"),
        _buildDetailRow("Price:", "Free"),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RouteSuggestionScreen()),
    );
          },
          icon: const Icon(Icons.location_on, color: Colors.white),
          label: const Text("Suggest a route", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text("$title ", style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)]),
    );
  }
}