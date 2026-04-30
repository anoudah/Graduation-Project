import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for user identification
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for fetching interests
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
    // Instead of a static string, we now fetch interests for the specific user.
    _recommendedEventsFuture = _fetchPersonalizedRecommendations();
    _trendingEventsFuture = _aiSource.fetchTrendingEvents();
    
    // 4. PRE-FETCHING (Performance Optimization)
    // Secretly download the search suggestions in the background so the 
    // Search Screen loads instantly when the user eventually clicks it.
    _aiSource.getSearchSuggestions(); 
  }

  // --- THE SMART FETCH LOGIC ---
  // This helper pulls the real interests (like Culture or AI) from the logged-in user's profile.
  Future<List<dynamic>> _fetchPersonalizedRecommendations() async {
    String queryInterest = "Culture"; // Default fallback for guests

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Access the specific user's document in the Firestore 'users' collection
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          var userInterests = userDoc.data()!['interests']; 

          if (userInterests != null) {
            if (userInterests is String) {
              queryInterest = userInterests;
            } else if (userInterests is List && userInterests.isNotEmpty) {
              // Joins multiple interests (e.g. "Museums and Heritage") for the AI backend
              queryInterest = userInterests.join(" and "); 
            }
          }
        }
      }
    } catch (e) {
      debugPrint("WASEL: Error fetching user interests: $e");
    }

    // Sends the dynamic interest string to your Python FastAPI backend
    return _aiSource.fetchRecommendations(queryInterest);
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
            HeroSlider(isMobile: isMobile, trendingFuture: _trendingEventsFuture),
            
            // Categories: Static list of buttons (Museums, Libraries, etc.)
            const CategoriesSection(),
            
            // Happening Now: Uses the same trending data as the slider
            HappeningNowSection(trendingFuture: _trendingEventsFuture),
            
            // Near You: Calculations for distance using GPS to show nearby events
            NearYouSection(eventsFuture: _trendingEventsFuture),
            
            // Recommended: Uses the dynamic AI logic based on user interests
            RecommendedSection(recommendedFuture: _recommendedEventsFuture), 
            
            // Smart Tour Banner: The call-to-action block at the very bottom
            const SmartTourBanner(),
          ],
        ),
      ),
    );
  }
}