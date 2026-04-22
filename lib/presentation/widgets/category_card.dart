import 'package:flutter/material.dart';
import '../screens/category_screen.dart';

class CategoryCard extends StatelessWidget {
  // We use dynamic here because the map contains both Strings (labels) and IconData
  final Map<String, dynamic> category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryScreen(
            categoryName: category['fullLabel'] as String,
            categoryId: category['fullLabel'] as String,
            categoryIcon: category['icon'] as IconData, // Casts the dynamic value back to IconData
          ),
        ),
      ),
      // Container holds the circle and the text below it
      child: Container(
        width: 90, // Fixed width ensures the text wraps properly under the circle
        margin: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            // CircleAvatar is a built-in Flutter widget perfect for circular icons/profile pics
            CircleAvatar(
              radius: 45, // Size of the circle
              backgroundColor: const Color(0xFFE8DDF5), // The light purple background
              child: Icon(
                category['icon'] as IconData,
                color: const Color(0xFF6B4B8A), // The dark purple icon color
                size: 44, // Size of the icon inside the circle
              ),
            ),
            const SizedBox(height: 12), // Space between the circle and the label
            Text(
              category['label'] as String,
              textAlign: TextAlign.center, // Centers the text directly under the circle
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}