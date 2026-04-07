import 'package:flutter/material.dart';
// تم التعديل هنا أيضاً
import '../../core/constants.dart';

Widget buildLibraryCard(String title, String image, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyles.commonShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(image, height: 100, width: 160, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
          ),
        ],
      ),
    ),
  );
}

Widget buildCategoryItem(IconData icon, String label) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppStyles.commonShadow),
        child: Icon(icon, color: AppColors.primaryPurple),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}