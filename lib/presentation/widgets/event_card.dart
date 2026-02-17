import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  // البيانات اللي تتغير حسب المكان
  final String title;
  final String imagePath;
  final String description;
  final String schedule;
  final String price;
  final String crowdStatus; // Low, Moderate, High
  final VoidCallback onSuggestRoute;

  const EventCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.schedule,
    required this.price,
    required this.crowdStatus,
    required this.onSuggestRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القسم الأيسر: الصورة والأيقونات التفاعلية
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(imagePath, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}), // ميزة المفضلة [cite: 846]
                    IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}), // ميزة التنبيهات [cite: 827]
                    IconButton(icon: const Icon(Icons.comment_outlined), onPressed: () {}), // ميزة التعليقات [cite: 826]
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                      child: const Text("I'm attending", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 30),
          // القسم الأيمن: المعلومات النصية [cite: 842]
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 15),
                const Text("Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildDetailRow("Schedule:", schedule),
                _buildDetailRow("Price:", price),
                _buildCrowdRow(crowdStatus), // ميزة توقع الزحام بالذكاء الاصطناعي [cite: 656]
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: onSuggestRoute,
                    icon: const Icon(Icons.location_on),
                    label: const Text("Suggest a route"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت مساعد لعرض تفاصيل الزحام بألوان ذكية
  Widget _buildCrowdRow(String status) {
    Color statusColor = status == "Low" ? Colors.green : (status == "Moderate" ? Colors.orange : Colors.red);
    return Row(
      children: [
        const Text("Crowd prediction: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
