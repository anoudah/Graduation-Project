import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/localization/localization_extension.dart';
import '../../application/providers/language_provider.dart';
import '../screens/category_screen.dart';
import 'category_card.dart';

class CategoriesSection extends StatelessWidget {
  // Adding the 'const' constructor is the secret to the performance boost!
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        // 1. ADDED BACKEND IDs: These match your Python API perfectly!
        final categories = [
          {'label': context.loc.libraries, 'icon': Icons.library_books, 'fullLabel': context.loc.librariesFull, 'id': 'LIB'},
          {'label': context.loc.heritageTradition, 'icon': Icons.museum, 'fullLabel': context.loc.heritageTraditionFull, 'id': 'HER'},
          {'label': context.loc.museums, 'icon': Icons.collections, 'fullLabel': context.loc.museumsFull, 'id': 'MUS'},
          {'label': context.loc.conferencesForums, 'icon': Icons.forum, 'fullLabel': context.loc.conferencesForumsFull, 'id': 'CONF'},
          {'label': context.loc.culturalInstitutions, 'icon': Icons.business, 'fullLabel': context.loc.culturalInstitutionsFull, 'id': 'INST'},
          {'label': context.loc.exhibitionConvention, 'icon': Icons.storefront, 'fullLabel': context.loc.exhibitionConventionFull, 'id': 'EXH'},
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.loc.categories, style: AppTextStyles.sectionTitle), 
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
      },
    );
  }
}