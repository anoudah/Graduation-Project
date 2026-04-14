import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasel/core/constants.dart';

class AiRemoteSource {
  
  // --- NEW: Chatbot Stream Method ---
  /// Connects to the FastAPI /chat endpoint and returns a stream of text chunks.
  Stream<String> getChatStream(String userQuery, {String? eventId}) async* {
    // 1. Construct the URL with optional event context
    final url = Uri.parse(
      '${AppConstants.aiBaseUrl}/chat?user_query=${Uri.encodeComponent(userQuery)}'
      '${eventId != null ? "&event_id=$eventId" : ""}'
    );

    try {
      // 2. We use http.Request + send() to handle StreamingResponse
      final request = http.Request('GET', url);
      request.headers.addAll({"ngrok-skip-browser-warning": "true"});

      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        // 3. Transform the byte stream into a readable UTF-8 String stream
        yield* response.stream
            .transform(utf8.decoder)
            .handleError((error) => "Connection interrupted...");
      } else {
        yield "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      yield "Connection failed. Please check your internet.";
    }
  }

  // --- 1. Fetch by Category ID ---
  Future<List<dynamic>> fetchEventsByCategoryId(String categoryId) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/category/$categoryId');
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_category_$categoryId';

    try {
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventsList = data['events'];
        await prefs.setString(cacheKey, json.encode(eventsList));
        return eventsList; 
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) return json.decode(cachedString);
      throw Exception('You are offline and no data is saved.');
    }
  }

  // --- 2. Fetch Smart Recommendations ---
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
        return recommendationsList;
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) return json.decode(cachedString);
      throw Exception('Offline: No recommendations saved.');
    }
  }

  // --- 3. Fetch Single Event by ID ---
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
        return eventData;
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) return json.decode(cachedString);
      throw Exception('Offline: Event not saved.');
    }
  }

  // --- 4. Fetch Trending Events ---
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
      final cachedString = prefs.getString(cacheKey);
      if (cachedString != null) return json.decode(cachedString);
      throw Exception('Offline: No trending data.');
    }
  }
}