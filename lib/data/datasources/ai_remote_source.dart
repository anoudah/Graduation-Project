import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // The new local storage package
import 'package:wasel/core/constants.dart'; // Make sure this path matches your constants file!

class AiRemoteSource {
  
  // 1. Fetch by Category (e.g., Museums, Exhibitions) with Offline Caching
  Future<List<dynamic>> fetchEventsByCategory(String categoryName) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/category?category_name=$categoryName');
    
    // Set up local storage and a unique key for this category
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_category_$categoryName';

    try {
      // TRY THE INTERNET FIRST (with a 5-second timeout)
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventsList = data['events'];

        // SAVE FOR LATER (The Cache)
        await prefs.setString(cacheKey, json.encode(eventsList));
        print("Live data fetched and cached securely for: $categoryName");
        
        return eventsList; 
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }

    } catch (e) {
      // OFFLINE FALLBACK
      print("Network connection failed. Attempting to load offline data for $categoryName...");

      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString != null) {
        // We found saved data! Return it to the UI.
        print("Success: Loaded $categoryName from offline cache.");
        return json.decode(cachedString);
      } else {
        // Offline AND no saved data
        throw Exception('You are offline and no data is saved for this category yet. Please connect to the internet.');
      }
    }
  }

  // 2. Fetch Smart Recommendations (e.g., "Art" or "Tech") with Offline Caching
  Future<List<dynamic>> fetchRecommendations(String interest) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/recommend?interest=$interest');
    
    // Set up local storage and a unique key for this interest
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_recommendation_$interest';

    try {
      // TRY THE INTERNET FIRST
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendationsList = data['recommendations'];
        
        // SAVE FOR LATER
        await prefs.setString(cacheKey, json.encode(recommendationsList));
        print("Live recommendations fetched and cached securely for: $interest");

        return recommendationsList;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // OFFLINE FALLBACK
      print("Network connection failed. Attempting to load offline recommendations for $interest...");

      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString != null) {
        print("Success: Loaded recommendations for $interest from offline cache.");
        return json.decode(cachedString);
      } else {
        throw Exception('You are offline and no recommendations are saved yet.');
      }
    }
  }
}