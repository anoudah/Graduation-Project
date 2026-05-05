import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasel/core/constants.dart';

class AiRemoteSource {
  // ===========================================================================
  // --- Chatbot Stream Method ---
  // ===========================================================================
  /// Connects to the FastAPI /chat endpoint and returns a stream of text chunks.
  Stream<String> getChatStream(
    String userQuery, {
    String? eventId,
    required String sessionId,
    String? userId,
  }) async* {
    // Construct the URL with the new parameters
    var urlString =
        '${AppConstants.aiBaseUrl}/chat?user_query=${Uri.encodeComponent(userQuery)}&session_id=$sessionId';
    if (eventId != null) urlString += '&event_id=$eventId';
    if (userId != null) urlString += '&user_id=$userId';

    final url = Uri.parse(urlString);

    try {
      // We use http.Request + send() to handle StreamingResponse
      final request = http.Request('GET', url);
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        // Transform the byte stream into a readable UTF-8 String stream
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

  // ===========================================================================
  // --- 1. Fetch by Category ID ---
  // ===========================================================================
  Future<List<dynamic>> fetchEventsByCategoryId(String categoryId) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/category/$categoryId');
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_category_$categoryId';

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

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

  // ===========================================================================
  // --- 2. Fetch Smart Recommendations ---
  // ===========================================================================
  // CHANGED HERE: Added optional userId parameter
  Future<List<dynamic>> fetchRecommendations(
    String interest, {
    String? userId,
  }) async {
    // CHANGED HERE: Append user_id to the URL if it exists
    var urlString = '${AppConstants.aiBaseUrl}/recommend?interest=$interest';
    if (userId != null && userId.isNotEmpty) {
      urlString += '&user_id=$userId';
    }

    final url = Uri.parse(urlString);
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_recommendation_$interest';

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

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

  // ===========================================================================
  // --- 3. Fetch Single Event by ID ---
  // ===========================================================================
  Future<Map<String, dynamic>> fetchEventById(String eventId) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/event/$eventId');
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_event_$eventId';

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

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

  // ===========================================================================
  // --- 4. Fetch Trending Events ---
  // ===========================================================================
  Future<List<dynamic>> fetchTrendingEvents() async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/trending');
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_trending';

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

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

  // ===========================================================================
  // --- 5. Search Events ---
  // ===========================================================================
  Future<List<dynamic>> searchEvents(String query) async {
    final url = Uri.parse(
      '${AppConstants.aiBaseUrl}/search?q=${Uri.encodeComponent(query)}',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during search.');
    }
  }

  // ===========================================================================
  // --- 6. Get Search Suggestions ---
  // ===========================================================================
  Future<List<String>> getSearchSuggestions() async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/suggestions');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['suggestions'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ===========================================================================
  // --- 7. Generate AI Smart Tour ---
  // ===========================================================================
  Future<Map<String, dynamic>> generateSmartTour({
    required double lat,
    required double lng,
    required double availableHours,
    required String preferences,
    String? localizedPreferences,
    String languageCode = 'en',
    required String startTime,
  }) async {
    final url = Uri.parse(
      '${AppConstants.aiBaseUrl}/generate-tour',
    ).replace(queryParameters: {'language': languageCode});
    final effectivePreferences = preferences.trim().isEmpty
        ? "Riyadh Culture"
        : preferences.trim();
    final effectiveLocalizedPreferences =
        localizedPreferences?.trim().isNotEmpty == true
        ? localizedPreferences!.trim()
        : effectivePreferences;

    final legacyPayload = {
      "user_lat": lat,
      "user_lng": lng,
      "available_hours": availableHours,
      "preferences": effectivePreferences,
      "start_time": startTime,
    };
    final localizedPayload = {
      ...legacyPayload,
      "language": languageCode,
      "response_language": languageCode == 'ar' ? "Arabic" : "English",
      "localized_preferences": effectiveLocalizedPreferences,
    };

    try {
      var response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(localizedPayload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 422) {
        response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(legacyPayload),
            )
            .timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['status'] == 'success') {
          return decodedData['tour'];
        } else {
          throw Exception(decodedData['message']);
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during AI Generation: $e');
    }
  }
}
