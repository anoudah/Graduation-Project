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

// --- Widget Imports ---
import '../widgets/category_card.dart';
import '../widgets/near_you_card.dart';
import '../widgets/compact_event_card.dart';

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
  late Future<List<dynamic>> _trendingEventsFuture; // NEW: For the "Happening Now" section

  @override
  void initState() {
    super.initState();
    // 3. FETCH DATA ON LOAD
    // Note: You can replace "Culture" with a variable from the user's actual profile later!
    _recommendedEventsFuture = _aiSource.fetchRecommendations("Culture");
    _trendingEventsFuture = _aiSource.fetchTrendingEvents(); // FETCH TRENDING
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background, 
      drawer: _buildDrawer(context),
      // --- ADD THIS BLOCK ---
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
      // ----------------------
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavigationBar(context),
            _HeroSlider(isMobile: isMobile, trendingFuture: _trendingEventsFuture),
            _buildCategoriesSection(context),
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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const TextField(
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
  //                     3. CATEGORIES SECTION (NOW CONNECTED)
  // ===========================================================================

  Widget _buildCategoriesSection(BuildContext context) {
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
          const Text('Categories', style: AppTextStyles.sectionTitle), 
          const SizedBox(height: 28),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                
                // 2. ADDED NAVIGATION: We wrap the card in a GestureDetector (or InkWell)
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

// =============================================================================
//                     2. HERO SLIDER WIDGET (NOW LIVE & CLICKABLE)
// =============================================================================

class _HeroSlider extends StatefulWidget {
  final bool isMobile;
  final Future<List<dynamic>> trendingFuture; // 1. Now accepts live data!

  const _HeroSlider({required this.isMobile, required this.trendingFuture, Key? key}) : super(key: key);

  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider> {
  int _currentSlideIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        // Note: We assume 3 trending events based on our Python backend
        int nextPage = _currentSlideIndex + 1;
        if (nextPage >= 3) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage, 
          duration: const Duration(milliseconds: 500), 
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 30, vertical: 30),
      // 2. Wrap the whole layout in a FutureBuilder to wait for the data
      child: FutureBuilder<List<dynamic>>(
        future: widget.trendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: widget.isMobile ? 250 : 350, 
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary))
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink(); // Hide slider if no data
          }

          final trendingEvents = snapshot.data!;
          
          return widget.isMobile 
              ? _buildMobile(trendingEvents) 
              : _buildDesktop(trendingEvents);
        }
      ),
    );
  }

  Widget _buildSlider(double height, List<dynamic> events) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView.builder( 
          controller: _pageController,
          itemCount: events.length,
          onPageChanged: (index) {
            setState(() => _currentSlideIndex = index);
          },
          itemBuilder: (context, index) {
            final event = Map<String, dynamic>.from(events[index]);
            
            // Image Safety Check (just like our cards)
            String imageUrl = event['Image_Url'] ?? '';
            if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
              imageUrl = 'https://placehold.co/800x400/png?text=Trending+Event';
            }

            // 3. Make it Clickable!
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LibraryDetailsScreen(eventData: event),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.network(imageUrl, fit: BoxFit.cover),
                  
                  // Dark Gradient Overlay for text readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.4, 1.0], // Starts fading to black halfway down
                      ),
                    ),
                  ),
                  
                  // Event Text Over the Image
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("🔥 TRENDING", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event['Title'] ?? 'Unknown Event',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['Category'] ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentSlideIndex ? AppColors.primary : AppColors.divider, 
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(List<dynamic> events) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Column(children: [_buildSlider(350, events), const SizedBox(height: 16), _buildDots(events.length)])),
        const SizedBox(width: 60),
        const Expanded(
          child: Text('SEE WHAT\nIS HAPPENING\nHERE', style: AppTextStyles.heroDesktop), 
        ),
      ],
    );
  }

  Widget _buildMobile(List<dynamic> events) {
    return Column(
      children: [
        _buildSlider(250, events),
        const SizedBox(height: 16),
        _buildDots(events.length),
        const SizedBox(height: 30),
        const Text('SEE WHAT IS HAPPENING HERE', textAlign: TextAlign.center, style: AppTextStyles.heroMobile),
      ],
    );
  }
}