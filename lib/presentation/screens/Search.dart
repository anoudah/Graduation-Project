import 'package:flutter/material.dart';
// استدعاء ملف الثيم - تأكدي من صحة المسار في مشروعك
import '../../core/theme.dart'; 

void main() {
  runApp(const EventsApp());
}

class EventsApp extends StatelessWidget {
  const EventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      home: const EventsHomePage(),
    );
  }
}

class EventsHomePage extends StatelessWidget {
  const EventsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // ربط الخلفية بالثيم
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background, 
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textMain), // لون الأيقونة
          onPressed: () {},
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.divider.withOpacity(0.2), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: AppColors.textHint), 
              prefixIcon: Icon(Icons.search, size: 20, color: AppColors.iconGrey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryLight, 
              child: Text('M', style: TextStyle(color: AppColors.primary)), 
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO SECTION
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.avatarBg, 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.image, size: 50, color: AppColors.iconGrey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Text(
                    'WHAT’S\nHAPPENING',
                    style: AppTextStyles.heroMobile.copyWith(
                      color: AppColors.textMain, 
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // CATEGORIES
            const SectionHeader(title: 'Categories'),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryChip(label: 'Libraries'),
                  CategoryChip(label: 'Heritage and Tradition'),
                  CategoryChip(label: 'Museums'),
                  CategoryChip(label: 'Conferences'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // NEAR YOU
            const SectionHeader(title: 'Near you'),
            const SizedBox(height: 12),
            NearbyCard(
              title: 'King Abdul Aziz Historical Center',
              distance: '2.3 km',
              color: Colors.orange[100]!,
            ),
            NearbyCard(
              title: 'King Fahad Cultural Center',
              distance: '4.1 km',
              color: Colors.blue[100]!,
            ),
            
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text('See more', style: TextStyle(color: AppColors.primary)), 
              ),
            ),
            const SizedBox(height: 24),

            // RECOMMENDED
            const SectionHeader(title: 'Recommended'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'No recommendations yet.',
                style: TextStyle(color: AppColors.textSecondary), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE COMPONENTS ---

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 20), 
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.textMain)),
      ),
    );
  }
}

class NearbyCard extends StatelessWidget {
  final String title;
  final String distance;
  final Color color;

  const NearbyCard({
    super.key,
    required this.title,
    required this.distance,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.place, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain),
                ),
                Text(
                  distance,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}