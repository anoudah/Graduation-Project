import 'package:flutter/material.dart';
import '../widgets/event_card.dart'; // تأكدي من مسار ملف الـ widget
// Alanoud added: Import the new AI Data Source we created
import '../../data/datasources/ai_remote_source.dart'; 

// Alanoud added: Changed to StatefulWidget to handle loading states
class MuseumsScreen extends StatefulWidget {
  const MuseumsScreen({super.key});

  @override
  State<MuseumsScreen> createState() => _MuseumsScreenState();
}

class _MuseumsScreenState extends State<MuseumsScreen> {
  // Alanoud added: Create an instance of our AI source and a Future variable to hold the data
  final AiRemoteSource _aiSource = AiRemoteSource();
  late Future<List<dynamic>> _museumEventsFuture;

  @override
  void initState() {
    super.initState();
    // Alanoud added: Ask Python for "Museums" category as soon as the screen opens
    _museumEventsFuture = _aiSource.fetchEventsByCategory("Museums");
  }

  @override
  Widget build(BuildContext context) {
    // Alanoud added: Deleted the hardcoded 'riyadhMuseums' list! The AI does this now.

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // لون خلفية فاتح
      appBar: AppBar(
        title: const Text(
          "Museums in Riyadh",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E), // لون الهوية (كحلي)
        elevation: 2,
        centerTitle: true,
      ),
      // Alanoud added: Replaced the standard ListView with a FutureBuilder to handle the API connection
      body: FutureBuilder<List<dynamic>>(
        future: _museumEventsFuture,
        builder: (context, snapshot) {
          
          // State 1: Still waiting for the Python AI to answer
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1A237E)),
                  SizedBox(height: 15),
                  Text("Wasel AI is calculating live crowds...", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          
          // State 2: Error connecting to Python (e.g., ngrok is down)
          if (snapshot.hasError) {
            return Center(
              child: Text("Connection Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
            );
          }

          // State 3: Successfully connected, but no museums were found in Firestore
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No museums found in the database at this time."),
            );
          }

          // State 4: Data successfully loaded! We extract the list.
          final museumsData = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: museumsData.length,
            itemBuilder: (context, index) {
              final museum = museumsData[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: EventCard(
                  // Alanoud added: Mapping the Python JSON keys (Title, Category, etc.) to the EventCard
                  title: museum['Title'] ?? "Unknown Museum",
                  // Providing a fallback image if Firestore doesn't have one
                  imagePath: museum['Image_Url'] ?? "https://pnu.edu.sa/en/Announcements/PublishingImages/museum.jpg", 
                  description: museum['About'] ?? museum['Category'] ?? "No description available.",
                  schedule: museum['Schedule'] ?? "Check Website",
                  price: museum['Price'] ?? "Free",
                  // Alanoud added: Directly feeding the dynamic AI output (LOW, MEDIUM, HIGH) into the UI!
                  crowdStatus: museum['Live_Crowd_Status'] ?? "LOW", 
                  onSuggestRoute: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Calculating the best route to ${museum['Title']}..."),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}