import 'package:flutter/material.dart';
import 'dart:async'; 
// --- Core Imports ---
import '../../core/theme.dart';
import '../../data/datasources/ai_remote_source.dart';

// --- Screen Imports ---
import 'category_screen.dart';
import 'smart_tour_screen.dart';
import 'favorites_screen.dart';
import 'contactus.dart';
import 'faq.dart';
import 'Nearyou.dart';
import 'Reminders.dart';
import 'profile.dart';
import 'library_details_screen.dart';
import 'chat_screen.dart';
import 'search.dart';

// --- Widget Imports ---
import '../widgets/category_card.dart';
import '../widgets/near_you_card.dart';
import '../widgets/compact_event_card.dart';
import '../widgets/hero_slider.dart';
import '../widgets/categories_section.dart';

// 1. CHANGED TO STATEFUL WIDGET
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. INITIALIZE THE AI SOURCE AND FUTURE
  final AiRemoteSource _aiSource = AiRemoteSource();
  late Future<List<dynamic>> _recommendedEventsFuture;
  late Future<List<dynamic>> _trendingEventsFuture; // For the "Happening Now" section
  

  @override
  void initState() {
    super.initState();
    // 3. FETCH DATA ON LOAD
    // Note: You can replace "Culture" with a variable from the user's actual profile later!
    _recommendedEventsFuture = _aiSource.fetchRecommendations("Culture");
    _trendingEventsFuture = _aiSource.fetchTrendingEvents(); // FETCH TRENDING
    _aiSource.getSearchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background, 
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavigationBar(context),
            HeroSlider(isMobile: isMobile, trendingFuture: _trendingEventsFuture),
            const CategoriesSection(),
            _buildHappeningNowSection(context),
            _buildNearYouSection(context), // Note: Left static for now until spatial data is ready
            _buildRecommendedSection(context), // AI Integration applied here!
            _buildBottomBannerSection(context),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  //                              DRAWER MENU
  // ===========================================================================

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Text('Options', style: TextStyle(color: AppColors.white, fontSize: 24)),
          ),
          _drawerTile(context, Icons.question_answer, 'FAQ', const FAQPage()),
          _drawerTile(context, Icons.mail_outline, 'Contact Us', const ContactUsScreen()),
          _drawerTile(context, Icons.favorite_border, 'Favorites', const FavoritesScreen()),
          _drawerTile(context, Icons.notifications, 'Reminders', const RemindersScreen()),
        ],
      ),
    );
  }

  ListTile _drawerTile(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }

 // ===========================================================================
  //                     1. NAVIGATION BAR SECTION
  // ===========================================================================

  Widget _buildNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textMain, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            // 1. ADDED: GestureDetector to handle the tap
            child: GestureDetector(
              onTap: () {
                // 2. ADDED: Push to the new SearchScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                ),
                // 3. ADDED: IgnorePointer stops the keyboard from opening on the Home Screen
                child: const IgnorePointer(
                  child: TextField(
                    readOnly: true, // Prevents typing on this specific screen
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      suffixIcon: Icon(Icons.search, color: AppColors.iconGrey, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
            child: const CircleAvatar(
              backgroundColor: AppColors.avatarBg,
              child: Icon(Icons.person, color: AppColors.iconGrey, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  //                     4. NEAR YOU SECTION
  // ===========================================================================

  Widget _buildNearYouSection(BuildContext context) {
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
            return NearYouCard(locationData: nearByLocations[index]);
          },
        ),
      ),
    );
  }

  // ===========================================================================
  //                     NEW: HAPPENING NOW SECTION
  // ===========================================================================

  Widget _buildHappeningNowSection(BuildContext context) {
    return _buildSectionLayout(
      context: context,
      title: "What's happening now",
      onSeeMore: () {}, 
      child: SizedBox(
        height: 240, 
        child: FutureBuilder<List<dynamic>>(
          future: _trendingEventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } 
            else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load live events.'));
            } 
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No live events right now.'));
            }

            final trendingEvents = snapshot.data!;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trendingEvents.length,
              itemBuilder: (context, index) {
                final eventData = Map<String, dynamic>.from(trendingEvents[index]);
                return CompactEventCard(eventData: eventData);
              },
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  //                     5. RECOMMENDED SECTION (NOW DYNAMIC)
  // ===========================================================================

  Widget _buildRecommendedSection(BuildContext context) {
    return _buildSectionLayout(
      context: context,
      title: 'Recommended',
      onSeeMore: () {}, 
      child: SizedBox(
        height: 240, 
        // 4. THE FUTURE BUILDER HANDLES ALL LOADING AND ERROR STATES
        child: FutureBuilder<List<dynamic>>(
          future: _recommendedEventsFuture,
          builder: (context, snapshot) {
            // While waiting for the Python AI...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } 
            // If the server crashes or internet drops (and no cache exists)
            else if (snapshot.hasError) {
              return Center(child: Text('Failed to load recommendations.', style: TextStyle(color: Colors.red.shade400)));
            } 
            // If it succeeds but returns an empty list
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No recommendations available right now.'));
            }

            // SUCCESS! Map the Python data to the UI
            final recommendations = snapshot.data!;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                // Ensure the map format matches what CompactEventCard expects
                final eventData = Map<String, dynamic>.from(recommendations[index]);
                return CompactEventCard(eventData: eventData);
              },
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  //                   REUSABLE LAYOUT HELPER (For Titles & See More)
  // ===========================================================================

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
                // ADDED EXPANDED FOR ANDROID APP: Prevents the title and button from overflowing on small phone screens
                Expanded(
                  child: Text(title, style: AppTextStyles.sectionTitle), 
                ),
                const SizedBox(width: 16), // Buffer space so the text doesn't touch the button
                ElevatedButton.icon(
                  onPressed: onSeeMore,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('See more'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          child, 
        ],
      ),
    );
  }

  // ===========================================================================
  //                     6. SMART TOUR BANNER SECTION
  // ===========================================================================

  Widget _buildBottomBannerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Divider(color: AppColors.divider, thickness: 1, height: 32),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text('Want to have a full day of culture?', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Generate a tour based on your interests', textAlign: TextAlign.center, style: AppTextStyles.subtitle),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmartTourScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text("Let's go", style: AppTextStyles.buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
