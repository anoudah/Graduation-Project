import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wasel/core/constants.dart'; // Make sure this path matches your constants file!

class AiRemoteSource {
  
  // 1. Fetch by Category (e.g., Museums, Exhibitions)
  Future<List<dynamic>> fetchEventsByCategory(String categoryName) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/category?category_name=$categoryName');
    
    try {
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['events']; // Returns the JSON list from Python
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("AI Source Error: $e");
      throw Exception('Failed to connect to Wasel AI');
    }
  }

  // 2. Fetch Smart Recommendations (e.g., "Art" or "Tech")
  Future<List<dynamic>> fetchRecommendations(String interest) async {
    final url = Uri.parse('${AppConstants.aiBaseUrl}/recommend?interest=$interest');
    
    try {
      final response = await http.get(
        url,
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['recommendations'];
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("AI Source Error: $e");
      throw Exception('Failed to connect to Wasel AI');
    }
  }
}