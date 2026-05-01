import 'package:flutter/material.dart';
import '../widgets/event_card.dart'; // تأكدي من مسار ملف الـ widget
// Alanoud added: Import the new AI Data Source we created
import '../../data/datasources/ai_remote_source.dart'; 
// استدعاء ملف الثيم
import '../../core/theme.dart';
import '../../core/localization/app_localizations.dart'; 

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
    // Alanoud added: Ask Python for "Museums" category using the clean REST ID
    _museumEventsFuture = _aiSource.fetchEventsByCategoryId("MUS");
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    // Alanoud added: Deleted the hardcoded 'riyadhMuseums' list! The AI does this now.

    return Scaffold(
      backgroundColor: AppColors.background, // تم الربط بالثيم (بدل F8F9FA)
      appBar: AppBar(
        title: Text(
          localizations.museumsInRiyadh,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E), // حافظت على الكحلي كما هو لأنه "لون هوية" خاص
        elevation: 2,
        centerTitle: true,
      ),
      // Alanoud added: Replaced the standard ListView with a FutureBuilder to handle the API connection
      body: FutureBuilder<List<dynamic>>(
        future: _museumEventsFuture,
        builder: (context, snapshot) {
          
                    if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF1A237E)),
                  const SizedBox(height: 15),
                  Text(localizations.waselAICalculatingCrowds, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          
          // State 2: Error connecting to Python (e.g., ngrok is down)
          if (snapshot.hasError) {
            return Center(
              child: Text('${localizations.connectionError}: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          // State 3: Successfully connected, but no museums were found in Firestore
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(localizations.noMuseumsFound),
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
                  title: museum['Title'] ?? localizations.unknownMuseum,
                  // Providing a fallback image if Firestore doesn't have one
                  imagePath: museum['Image_Url'] ?? "https://pnu.edu.sa/en/Announcements/PublishingImages/museum.jpg", 
                  description: museum['About'] ?? museum['Category'] ?? localizations.noDescriptionAvailable,
                  schedule: museum['Schedule'] ?? localizations.checkWebsite,
                  price: museum['Price'] ?? localizations.free,
                  // Alanoud added: Directly feeding the dynamic AI output (LOW, MEDIUM, HIGH) into the UI!
                  crowdStatus: museum['Live_Crowd_Status'] ?? "LOW", 
                  onSuggestRoute: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations.calculatingRoute} ${museum['Title']}...'),
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