import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../../core/theme.dart';
import '../../core/localization/app_localizations.dart'; 
import '../../core/utils/bilingual_helper.dart'; // Import for language support

/// A screen that displays events the user has marked as favorites.
/// 
/// This screen listens to real-time updates from 'User_Interactions' and
/// fetches full event details from the 'Events' collection.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          localizations.myFavorites,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: userId == null
          ? Center(child: Text(localizations.pleaseLoginToSeeFavorites))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User_Interactions')
                  .where('User_Id', isEqualTo: userId)
                  .where('Favorite', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(localizations.noFavoritesFound));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var interaction = snapshot.data!.docs[index];
                    
                    // --- Defensive check for empty IDs ---
                    // This prevents the "document path must be a non-empty string" error.
                    String eventId = interaction['id'] ?? '';

                    if (eventId.isEmpty) {
                      return const SizedBox.shrink(); // Skip broken records
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Events')
                          .doc(eventId)
                          .get(),
                      builder: (context, eventSnapshot) {
                        if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        var eventData = eventSnapshot.data!.data() as Map<String, dynamic>;

                        // Resolve bilingual text based on current language
                        String title = BilingualHelper.getText(eventData['Title'], context);
                        String about = BilingualHelper.getText(eventData['About'] ?? eventData['Description'], context);
                        String schedule = BilingualHelper.getText(eventData['Schedule'], context);
                        
                        // Handle Price with Custom Riyal Symbol Image
                        String rawPrice = BilingualHelper.getText(eventData['Price'] ?? eventData['price'], context);
                        bool isFree = rawPrice.isEmpty || rawPrice == "0";
                        
                        Widget priceWidget = isFree 
                          ? Text(Directionality.of(context) == TextDirection.rtl ? 'مجاني' : 'Free', 
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(rawPrice, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Image.asset(
                                  'assets/images/riyal_symbol.png',
                                  height: 12,
                                  color: AppColors.primary,
                                  errorBuilder: (context, error, stackTrace) => const Text(' SAR', 
                                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: EventCard(
                            title: title.isEmpty ? 'No Title' : title,
                            imagePath: eventData['Image_Url'] ?? eventData['Image'] ?? '',
                            description: about,
                            schedule: schedule,
                            price: priceWidget, // Now passing the custom Widget
                            crowdStatus: eventData['Crowd prediction'] ?? 'Normal',
                            onSuggestRoute: () {
                              // Logic for opening maps can be added here
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}