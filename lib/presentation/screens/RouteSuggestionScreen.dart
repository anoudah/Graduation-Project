import 'package:flutter/material.dart';
// استدعاء ملف الثيم
import '../../core/theme.dart'; 

class RouteSuggestionScreen extends StatelessWidget {
  const RouteSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // تم الربط بخلفية الثيم
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textMain), // ربط لون زر الرجوع
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
                color: AppColors.divider.withOpacity(0.3), // استخدام لون الفواصل من الثيم
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search',
                  hintStyle: TextStyle(color: AppColors.textHint), // ربط لون التلميح
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: AppColors.iconGrey), // ربط لون الأيقونة
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
                        Text('Suggested Route To', style: AppTextStyles.heroMobile.copyWith(color: AppColors.textMain, height: 1.1)),
                        Text('Saudi National\nMuseum', style: AppTextStyles.heroMobile.copyWith(color: AppColors.textMain, height: 1.1)),
                        const SizedBox(height: 40),
                        Text('Based on your location:', style: AppTextStyles.subtitle), // ربط ستايل النص الفرعي
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
                        Text('Future Trip:', style: AppTextStyles.subtitle),
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
                            backgroundColor: const Color(0xFF1A1F71), // تركته كحلي كما في الصورة
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
                VerticalDivider(thickness: 1.5, width: 1, color: AppColors.divider, indent: 20, endIndent: 80),

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
                            border: Border.all(color: AppColors.divider),
                            image: const DecorationImage(
                              image: NetworkImage('https://via.placeholder.com/500x400?text=Map+View'), 
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // زر View in Google Maps
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.location_on, size: 20, color: AppColors.primary),
                          label: const Text('View in Google Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight, // اللون الفاتح من الثيم
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
        color: isSelected ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.iconGrey),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : AppColors.textMain)),
        ],
      ),
    );
  }

  // ويدجت صناديق التاريخ والوقت
  Widget _buildInputBox(String title, String val, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle),
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
              Icon(icon, size: 18, color: AppColors.iconGrey),
            ],
          ),
        ),
      ],
    );
  }
}