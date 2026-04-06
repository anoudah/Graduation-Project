import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RouteSuggestionScreen.dart';

class LibraryDetailsScreen extends StatefulWidget {
  final String eventId;

  const LibraryDetailsScreen({super.key, required this.eventId});

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    // أهم جزء: جلب البيانات بناءً على الـ ID الممرر
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.eventId)
          .get(),
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            ),
          );
        }

        // حالة الخطأ أو عدم وجود بيانات
        if (snapshot.hasError || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("المعذرة، لم يتم العثور على التفاصيل")),
          );
        }

        // تحويل البيانات لقاموس (Map) لسهولة الاستخدام
        var eventData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: _buildTopNav(
              eventData['Category'] ?? "تفاصيل",
            ), // تصنيف ديناميكي
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
                      // تمرير البيانات للدوال الفرعية
                      Expanded(flex: 1, child: _buildImageSection(eventData)),
                      const SizedBox(width: 40),
                      Expanded(flex: 1, child: _buildInfoSection(eventData)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // قسم الصورة صار يستقبل 'data'
  Widget _buildImageSection(Map<String, dynamic> data) {
    return Column(
      children: [
        Text(
          data['Title'] ?? "بدون عنوان",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            data['Image_Url'] ?? '',
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 350,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 100),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () => setState(() => isFavorite = !isFavorite),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {},
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "I'm attending",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopNav(String category) {
    return Text(
      category,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 500,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "search",
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(data['About'] ?? "لا يوجد وصف متوفر حالياً."),
        const SizedBox(height: 20),
        const Text(
          "Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        _buildDetailRow("Schedule:", data['Schedule'] ?? "غير محدد"),
        _buildDetailRow("Price:", data['Price'] ?? "مجاني"),
        _buildDetailRow("Location:", data['Location_Address'] ?? "الرياض"),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RouteSuggestionScreen(),
              ),
            );
          },
          icon: const Icon(Icons.location_on, color: Colors.white),
          label: const Text(
            "Suggest a route",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
