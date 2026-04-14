import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Local storage package
import 'package:wasel/core/constants.dart'; // Make sure this path matches your constants file!

class AiRemoteSource {
  
  // 1. Fetch by Category ID (e.g., "MUS", "EXH") with Offline Caching
  Future<List<dynamic>> fetchEventsByCategoryId(String categoryId) async {
    // UPDATED: Now points to the clean REST path instead of query params
    final url = Uri.parse('${AppConstants.aiBaseUrl}/category/$categoryId');
    
    // Set up local storage and a unique key for this category
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_category_$categoryId';

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
        print("Live data fetched and cached securely for Category ID: $categoryId");
        
        return eventsList; 
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }

    } catch (e) {
      // OFFLINE FALLBACK
      print("Network connection failed. Attempting to load offline data for $categoryId...");

      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString != null) {
        // We found saved data! Return it to the UI.
        print("Success: Loaded $categoryId from offline cache.");
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
    
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_recommendation_$interest';

    try {
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final recommendationsList = data['recommendations'];
        
        await prefs.setString(cacheKey, json.encode(recommendationsList));
        print("Live recommendations fetched and cached securely for: $interest");

        return recommendationsList;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
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

  // 3. NEW: Fetch Single Event by ID with Offline Caching
  Future<Map<String, dynamic>> fetchEventById(String eventId) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/event/$eventId');
    
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_event_$eventId';

    try {
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventData = data['event'];
        
        await prefs.setString(cacheKey, json.encode(eventData));
        print("Live event data fetched and cached securely for: $eventId");

        return eventData;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Network connection failed. Attempting to load offline event data for $eventId...");

      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString != null) {
        print("Success: Loaded event $eventId from offline cache.");
        return json.decode(cachedString);
      } else {
        throw Exception('You are offline and this event is not saved yet.');
      }
    }
  }
  // 4. Fetch Trending / Happening Now (Top 3)
  Future<List<dynamic>> fetchTrendingEvents() async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/trending');
    
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_trending';

    try {
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trendingList = data['events'];
        
        await prefs.setString(cacheKey, json.encode(trendingList));
        return trendingList;
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      print("Network failed. Loading offline Trending data...");
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) {
        return json.decode(cachedString);
      } else {
        throw Exception('Offline and no trending data saved.');
      }
    }
  }
}