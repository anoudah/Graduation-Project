import 'package:flutter/material.dart';

// --- Screen Imports ---
import 'category_screen.dart';
import 'smart_tour_screen.dart';
import 'favorites_screen.dart';
import 'contactus.dart';
import 'faq.dart';
import 'Nearyou.dart';
import 'Reminders.dart';
import 'profile.dart';

// --- Widget Imports ---
// Importing the modular widgets we just created 
import '../widgets/category_card.dart';
import '../widgets/near_you_card.dart';
import '../widgets/compact_event_card.dart';

/// The Home Screen is now a StatelessWidget. 
/// Why? Because the only part of this screen that actually changes state 
/// (needs to rebuild) is the image slider at the top. Moving the slider 
/// into its own widget prevents the entire screen from lagging when you swipe!
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the screen is mobile or web/tablet to adjust the layout dynamically
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavigationBar(context),
            // The stateful slider is called here. It handles its own rebuilding.
            _HeroSlider(isMobile: isMobile), 
            _buildCategoriesSection(context),
            _buildNearYouSection(context),
            _buildRecommendedSection(context),
            _buildBottomBannerSection(context),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UI SECTIONS
  // ==========================================

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF6B4B8A)),
            child: Text('Options', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _drawerTile(context, Icons.question_answer, 'FAQ', const FAQPage()),
          _drawerTile(context, Icons.mail_outline, 'Contact Us', const ContactUsScreen()),
          _drawerTile(context, Icons.favorite_border, 'Favorites', const FavoritesScreen()),
          _drawerTile(context, Icons.notifications, 'Reminders', const RemindersScreen()),
        ],
      ),
    );
  }

  // Helper method to keep drawer code clean
  ListTile _drawerTile(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // PERFORMANCE UPGRADE: We use a Builder here instead of a GlobalKey.
          // This gives the IconButton a context that is "inside" the Scaffold,
          // allowing it to open the drawer without keeping an expensive global key in memory.
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF333333), size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 16),
          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  suffixIcon: Icon(Icons.search, color: Color(0xFF666666), size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Profile Button
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
            child: const CircleAvatar(
              backgroundColor: Color(0xFFDDDDDD),
              child: Icon(Icons.person, color: Color(0xFF666666), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    // Mock data (This will eventually come from your Domain/Data layer [cite: 31, 41])
    final categories = [
      {'label': 'Libraries', 'icon': Icons.library_books, 'fullLabel': 'Libraries'},
      {'label': 'Heritage and\nTradition', 'icon': Icons.museum, 'fullLabel': 'Heritage and Tradition'},
      {'label': 'Museums', 'icon': Icons.collections, 'fullLabel': 'Museums'},
      {'label': 'Conferences\nand Forums', 'icon': Icons.forum, 'fullLabel': 'Conferences and Forums'},
      {'label': 'Cultural\nInstitutions', 'icon': Icons.business, 'fullLabel': 'Cultural Institutions'},
      {'label': 'Exhibition and\nConvention', 'icon': Icons.storefront, 'fullLabel': 'Exhibition and Convention Centre'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),
          SizedBox(
            height: 140, // Fixed height required for horizontal list view
            // PERFORMANCE UPGRADE: ListView.builder lazily loads items.
            // It only renders the widgets that are currently visible on the screen!
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                // Calls your modular widget!
                return CategoryCard(category: categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearYouSection(BuildContext context) {
    // Mock data
    final nearByLocations = [
      {'name': 'King Abdul Aziz Historical Center', 'distance': '2.3 km'},
      {'name': 'King Fahad Cultural Center', 'distance': '4.1 km'},
      {'name': 'Saudi National Museum', 'distance': '5.2 km'},
    ];

    return _buildSectionLayout(
      context: context,
      title: 'Near you',
      onSeeMore: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearYouScreen())),
      child: SizedBox(
        height: 124, 
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: nearByLocations.length,
          itemBuilder: (context, index) {
             // Calls your modular widget!
            return NearYouCard(locationData: nearByLocations[index]);
          },
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    // Mock data matching the structure needed for LibraryDetailsScreen
    final recommendations = [
      {'Title': 'King Fahad National Library', 'id': 'lib_01', 'Image_Url': 'https://placehold.co/220x160/png?text=Library', 'Category': 'Libraries', 'About': 'A special viewing of rare historical Islamic manuscripts.', 'Location_Address': 'King Fahad National Library', 'Price': 'Free'},
      {'Title': 'Diriyah Historical Tour', 'id': 'her_01', 'Image_Url': 'https://placehold.co/220x160/png?text=Diriyah', 'Category': 'Heritage and Tradition', 'About': 'Walk through the birthplace of the Kingdom. A guided evening tour.', 'Location_Address': 'At-Turaif, Diriyah', 'Price': '150 SAR'},
      {'Title': 'Al Masmak Palace Exhibition', 'id': 'mus_02', 'Image_Url': 'https://placehold.co/220x160/png?text=Masmak', 'Category': 'Museums', 'About': 'Walk through the mud-brick fortress that played a vital role in the Kingdom\'s unification.', 'Location_Address': 'Al Diriyah, Riyadh', 'Price': 'Free'},
    ];

    return _buildSectionLayout(
      context: context,
      title: 'Recommended',
      onSeeMore: () {}, // Add navigation to a "See All" screen later
      child: SizedBox(
        height: 240, 
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
             // Calls your modular widget!
            return CompactEventCard(eventData: recommendations[index]);
          },
        ),
      ),
    );
  }

  // ==========================================
  // REUSABLE LAYOUT HELPERS
  // ==========================================

  /// Reusable layout wrapper for sections that have a "Title" and a "See More" button
  Widget _buildSectionLayout({required BuildContext context, required String title, required VoidCallback onSeeMore, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                ElevatedButton.icon(
                  onPressed: onSeeMore,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('See more'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4B8A), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          child, // The horizontal list gets injected here
        ],
      ),
    );
  }

  Widget _buildBottomBannerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Divider(color: Color(0xFFD0D0D0), thickness: 1, height: 32),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text('Want to have a full day of culture?', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Generate a tour based on your interests', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF999999))),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmartTourScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4B8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text("Let's go", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ISOLATED STATEFUL WIDGET
// ==========================================

/// Extracted Hero Slider.
/// By placing this in its own StatefulWidget, ONLY the slider rebuilds when 
/// the user swipes to a new image, instead of the entire Home Screen.
class _HeroSlider extends StatefulWidget {
  final bool isMobile;
  const _HeroSlider({required this.isMobile, Key? key}) : super(key: key);

  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider> {
  int _currentSlideIndex = 0;
  
  final List<String> imagePlaceholders = [
    'https://via.placeholder.com/400x300?text=Event+1',
    'https://via.placeholder.com/400x300?text=Event+2',
    'https://via.placeholder.com/400x300?text=Event+3',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 30, vertical: 30),
      child: widget.isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  Widget _buildSlider(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView.builder( // Lazy loading for the images in the slider
          itemCount: imagePlaceholders.length,
          onPageChanged: (index) {
            // ONLY this small widget rebuilds when the state changes!
            setState(() => _currentSlideIndex = index);
          },
          itemBuilder: (context, index) => Image.network(imagePlaceholders[index], fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        imagePlaceholders.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentSlideIndex ? const Color(0xFF6B4B8A) : const Color(0xFFD0D0D0),
          ),
        ),
      ),
    );
  }

  // Layout specifically for larger screens (tablets/web)
  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Column(children: [_buildSlider(350), const SizedBox(height: 16), _buildDots()])),
        const SizedBox(width: 60),
        const Expanded(
          child: Text('SEE WHAT\nIS HAPPENING\nHERE', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.3)),
        ),
      ],
    );
  }

  // Layout specifically for mobile screens
  Widget _buildMobile() {
    return Column(
      children: [
        _buildSlider(250),
        const SizedBox(height: 16),
        _buildDots(),
        const SizedBox(height: 30),
        const Text('SEE WHAT IS HAPPENING HERE', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3)),
      ],
    );
  }
}