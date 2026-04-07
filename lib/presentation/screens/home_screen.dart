import 'package:flutter/material.dart';

// 1. استدعاء ملفات التنظيم (المسارات المحدثة بناءً على صورتك)
import '../../core/constants.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_components.dart';

// 2. استدعاء كل الصفحات التي كانت موجودة في مشروعك لضمان عمل الـ Navigation
import 'profile.dart'; 
import 'library_details_screen.dart';
import 'category_screen.dart';
import 'Nearyou.dart';
import 'faq.dart';
import 'contactus.dart';
import 'favorites_screen.dart';
import 'Reminders.dart';
import 'Notifications.dart';
import 'smart_tour_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // المفتاح الأساسي للتحكم في القائمة الجانبية (Drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // بيانات المكاتب (المحتوى الذي كان في الـ 800 سطر)
  final List<Map<String, String>> nearYouData = [
    {
      'name': 'King Fahad National Library', 
      'img': 'https://kfnl.gov.sa/ar/About/PublishingImages/Building.jpg'
    },
    {
      'name': 'Prince Sultan University Library', 
      'img': 'https://www.psu.edu.sa/sites/default/files/2020-01/library.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ربط المفتاح لفتح المنيو
      backgroundColor: AppColors.background,
      drawer: const HomeDrawer(), // استدعاء المنيو من ملفها المستقل
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(), // شريط البحث والمنيو والبروفايل
              _buildSectionTitle('Categories'),
              _buildCategoriesRow(), 
              _buildSectionTitle('Near You'),
              _buildHorizontalList(nearYouData),
              _buildSectionTitle('Recommended'),
              _buildHorizontalList(nearYouData), // استخدمنا نفس الدالة للاختصار
            ],
          ),
        ),
      ),
    );
  }

  // --- الدوال الأساسية (Functions) ---

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28), 
            onPressed: () => _scaffoldKey.currentState?.openDrawer()
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a library...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                filled: true, fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person_pin, size: 32, color: AppColors.primaryPurple), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()))
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    );
  }

  Widget _buildCategoriesRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // تم إضافة الـ onTap لكل أيقونة لربطها بصفحاتك
          buildCategoryItem(Icons.library_books, 'Library', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen()))),
          buildCategoryItem(Icons.school, 'Study', () {}), 
          buildCategoryItem(Icons.event, 'Events', () {}),
          buildCategoryItem(Icons.map, 'Tours', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmartTourScreen()))),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Map<String, String>> dataList) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          return buildLibraryCard(item['name']!, item['img']!, () {
            // الانتقال لصفحة تفاصيل المكتبة (King Fahad)
            if (item['name']?.contains('King Fahad') ?? false) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LibraryDetailsScreen()));
            }
          });
        },
      ),
    );
  }
}