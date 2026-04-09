import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsHomePage extends StatefulWidget {
  const EventsHomePage({super.key});

  @override
  State<EventsHomePage> createState() => _EventsHomePageState();
}

class _EventsHomePageState extends State<EventsHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _userFirstName = "U"; // القيمة الافتراضية

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // تدقيق: الكولكشن Users والحقل Full_Name
        var userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (userData.exists && userData.data() != null) {
          String fullName = userData.data()!['Full_Name'] ?? "User";
          if (mounted) {
            setState(() {
              _userFirstName = fullName.isNotEmpty
                  ? fullName[0].toUpperCase()
                  : "U";
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search Events or Categories...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = "");
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              // التعديل المجهري: استخدام withValues بدل withOpacity
              backgroundColor: const Color(0xFF6B4B8A).withValues(alpha: 0.2),
              child: Text(
                _userFirstName,
                style: const TextStyle(
                  color: Color(0xFF6B4B8A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No events found in database."));
          }

          // فلطرة مجهرية بناءً على مسميات Firestore الحقيقية
          var filteredEvents = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // تدقيق: الحقل يبدأ بحرف كبير Title و Category
            String title = (data['Title'] ?? "").toString().toLowerCase();
            String category = (data['Category'] ?? "").toString().toLowerCase();

            return title.contains(_searchQuery) ||
                category.contains(_searchQuery);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 32),
                const SectionHeader(title: 'Categories'),
                const SizedBox(height: 12),
                _buildCategoriesList(),
                const SizedBox(height: 32),
                const SectionHeader(title: 'Near you'),
                const SizedBox(height: 12),

                if (filteredEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No match found."),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      var event =
                          filteredEvents[index].data() as Map<String, dynamic>;
                      return NearbyCard(
                        // تدقيق مجهري: Title و Location_Address
                        title: event['Title'] ?? "No Title",
                        distance:
                            event['Location_Address'] ?? "Unknown Location",
                        color: (index % 2 == 0)
                            ? Colors.orange[100]!
                            : Colors.blue[100]!,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              // التعديل المجهري: استخدام withValues بدل withOpacity
              color: const Color(0xFF6B4B8A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.celebration,
              size: 50,
              color: Color(0xFF6B4B8A),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'WHAT’S\nHAPPENING',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList() {
    final categories = [
      'Conferences and Forums',
      'Exhibition and Convention',
      'Heritage and Tradition',
      'Cultural Institutions',
      'Libraries',
      'Museums',
    ];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => CategoryChip(label: categories[index]),
      ),
    );
  }
}

// --- الكلاسات المساعدة (Widgets) ---

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  );
}

class CategoryChip extends StatelessWidget {
  final String label;
  const CategoryChip({super.key, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(child: Text(label, style: const TextStyle(fontSize: 14))),
  );
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
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        // التعديل المجهري: استخدام withValues بدل withOpacity
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                distance,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
