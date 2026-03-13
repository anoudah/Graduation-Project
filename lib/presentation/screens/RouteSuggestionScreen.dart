import 'package:flutter/material.dart';

class RouteSuggestionScreen extends StatelessWidget {
  const RouteSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF), // خلفية فاتحة جداً مثل الصورة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. شريط البحث العلوي بنفس تصميم الصورة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 300), 
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'search',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),

          Expanded(
            child: Row(
              children: [
                // 2. القسم الأيسر: نصوص ومدخلات
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 80, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Suggested Route To', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.1)),
                        const Text('Saudi National\nMuseum', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.1)),
                        const SizedBox(height: 40),
                        const Text('Based on your location:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 15),
                        
                        // أيقونات النقل (سيارة، قطار، مشي)
                        Row(
                          children: [
                            _buildTransportIcon(Icons.directions_car, '30 min', true),
                            _buildTransportIcon(Icons.train, '55 min', false),
                            _buildTransportIcon(Icons.directions_walk, '2.3 h', false),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        const Text('Future Trip:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 15),
                        
                        // خانات التاريخ والوقت (Date & Time)
                        Row(
                          children: [
                            _buildInputBox('Date', '08/17/2025', Icons.calendar_today),
                            const SizedBox(width: 15),
                            _buildInputBox('Time', '17:35', Icons.access_time),
                          ],
                        ),
                        
                        const SizedBox(height: 50),
                        // زر Suggest route الكحلي
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Suggest route', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1F71),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. الخط الفاصل الرأسي (الموجود بالصورة)
                const VerticalDivider(thickness: 1.5, width: 1, color: Color(0xFFE0E0E0), indent: 20, endIndent: 80),

                // 4. القسم الأيمن: الخريطة وزر جوجل مابس
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // إطار الخريطة
                        Container(
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            image: const DecorationImage(
                              image: NetworkImage('https://via.placeholder.com/500x400?text=Map+View'), // استبدليها بـ Asset Image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // زر View in Google Maps
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.location_on, size: 20),
                          label: const Text('View in Google Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7FF),
                            foregroundColor: const Color(0xFF1A1F71),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت أيقونات النقل
  Widget _buildTransportIcon(IconData icon, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE1F5FE) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.black),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.blue : Colors.black)),
        ],
      ),
    );
  }

  // ويدجت صناديق التاريخ والوقت
  Widget _buildInputBox(String title, String val, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1A1F71), width: 1.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.w500)),
              Icon(icon, size: 18, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }
}