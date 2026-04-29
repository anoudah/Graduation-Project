import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';
import '../screens/category_screen.dart';
import 'category_card.dart';

class CategoriesSection extends StatelessWidget {
  // Adding the 'const' constructor is the secret to the performance boost!
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. ADDED BACKEND IDs: These match your Python API perfectly!
    final categories = [
      {'label': 'Libraries', 'icon': Icons.library_books, 'fullLabel': 'Libraries', 'id': 'LIB'},
      {'label': 'Heritage and\nTradition', 'icon': Icons.museum, 'fullLabel': 'Heritage and Tradition', 'id': 'HER'},
      {'label': 'Museums', 'icon': Icons.collections, 'fullLabel': 'Museums', 'id': 'MUS'},
      {'label': 'Conferences\nand Forums', 'icon': Icons.forum, 'fullLabel': 'Conferences and Forums', 'id': 'CONF'},
      {'label': 'Cultural\nInstitutions', 'icon': Icons.business, 'fullLabel': 'Cultural Institutions', 'id': 'INST'},
      {'label': 'Exhibition and\nConvention', 'icon': Icons.storefront, 'fullLabel': 'Exhibition and Convention Centre', 'id': 'EXH'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) => Text(context.loc.categories, style: AppTextStyles.sectionTitle),
          ), 
          const SizedBox(height: 28),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                
                // 2. ADDED NAVIGATION: We wrap the card in a GestureDetector
                return GestureDetector(
                  onTap: () {
                    // 3. PUSH TO NEW SCREEN: Send the specific ID and Name to the Category Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryScreen(
                          categoryId: category['id'] as String,
                          categoryName: category['fullLabel'] as String,
                          categoryIcon: category['icon'] as IconData,
                        ),
                      ),
                    );
                  },
                  child: CategoryCard(category: category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}