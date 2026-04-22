import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/datasources/ai_remote_source.dart';

// --- Screen Imports ---
// These are the full-page screens that the user navigates to from the home page
import 'chat_screen.dart';

// --- Widget Imports (The Modular Architecture) ---
// By importing these sections instead of writing them here, 
// we keep this main file incredibly fast, readable, and easy to debug.
import '../widgets/app_drawer.dart'; 
import '../widgets/home_top_bar.dart'; 
import '../widgets/hero_slider.dart';
import '../widgets/categories_section.dart';
import '../widgets/happening_now_section.dart'; 
import '../widgets/near_you_section.dart'; 
import '../widgets/recommended_section.dart';
import '../widgets/smart_tour_banner.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. DATA SOURCE
  // We initialize the connection to the Python/Firebase backend here
  final AiRemoteSource _aiSource = AiRemoteSource();
  
  // 2. STATE VARIABLES
  // We use 'late Future' because we will assign these values in initState.
  // Passing these Futures down to the child widgets prevents the whole 
  // screen from freezing while waiting for the internet.
  late Future<List<dynamic>> _recommendedEventsFuture;
  late Future<List<dynamic>> _trendingEventsFuture; 

  @override
  void initState() {
    super.initState();
    // 3. FETCH DATA ON LOAD
    // As soon as the screen opens, we ask the database for the data.
    _recommendedEventsFuture = _aiSource.fetchRecommendations("Culture");
    _trendingEventsFuture = _aiSource.fetchTrendingEvents();
    
    // 4. PRE-FETCHING (Performance Optimization)
    // Secretly download the search categories in the background so the 
    // Search Screen loads instantly when the user eventually clicks it.
    _aiSource.getSearchSuggestions(); 
  }

  @override
  Widget build(BuildContext context) {
    // 5. RESPONSIVE DESIGN CHECK
    // Determines if the user is on a phone or a wider screen (like web/tablet)
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background, 
      
      // --- SIDE NAVIGATION ---
      // The hamburger menu slides this drawer out.
      drawer: const AppDrawer(), 
      
      // --- FLOATING CHAT BUTTON ---
      // The AI assistant button that hovers in the bottom right corner.
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),
      
      // --- MAIN CONTENT AREA ---
      // SingleChildScrollView allows the user to scroll vertically if the screen is small.
      body: SingleChildScrollView(
        // The Column acts as our "Table of Contents", stacking our modular widgets.
        child: Column(
          children: [
            // Top Bar: Contains Menu Icon, Search Bar, and Profile Icon
            const HomeTopBar(),
            
            // Hero Slider: The auto-playing trending images at the top.
            // We pass the data future into it so it manages its own loading spinner.
            HeroSlider(isMobile: isMobile, trendingFuture: _trendingEventsFuture),
            
            // Categories: Static list of buttons (Museums, Libraries, etc.)
            // Marked as 'const' so Flutter only draws it once to save battery/CPU.
            const CategoriesSection(),
            
            // Happening Now: Uses the same trending data as the slider
            HappeningNowSection(trendingFuture: _trendingEventsFuture),
            
            // Near You: The section that calculates distance using the user's GPS and shows nearby events
            NearYouSection(eventsFuture: _trendingEventsFuture),
            
            // Recommended: Uses the AI logic to fetch personalized events
            RecommendedSection(recommendedFuture: _recommendedEventsFuture), 
            
            // Smart Tour Banner: The call-to-action block at the very bottom
            const SmartTourBanner(),
          ],
        ),
      ),
    );
  }
}