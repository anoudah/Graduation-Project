import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/bilingual_helper.dart'; 
import '../../core/theme.dart';

/// A screen that displays a list of events the user has marked for reminders.
/// 
/// This screen implements a "Nested Fetch" pattern:
/// 1. It listens to a real-time stream of the 'User_Interactions' collection.
/// 2. For each interaction found, it fetches the corresponding event details 
///    from the 'Events' collection using the event ID.
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieves the unique ID of the currently authenticated Firebase user.
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).yourReminders,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary, 
        centerTitle: true,
      ),
      // --- DATA LAYER: User Interactions Stream ---
      // Monitors User_Interactions for documents where 'Reminder' is true for this user.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User_Interactions')
            .where('User_Id', isEqualTo: currentUserId) 
            .where('Reminder', isEqualTo: true) 
            .snapshots(),
        builder: (context, snapshot) {
          // Standard loading state while the stream initializes.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Empty state handling if no reminders are found.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).noRemindersCurrently),
            );
          }

          final reminderDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reminderDocs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Extract the individual interaction document.
              final interaction =
                  reminderDocs[index].data() as Map<String, dynamic>;
              
              // --- THE FIX: Extract and validate the event ID ---
              // If 'id' is null or empty, we must skip the fetch to avoid the ArgumentError.
              final String eventId = interaction['id'] ?? '';

              if (eventId.isEmpty) {
                return const SizedBox.shrink(); // Silently skip broken database records.
              }

              // --- DATA LAYER: Event Details Fetch ---
              // Fetches full Event details (Title, Schedule) from the 'Events' collection.
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Events')
                    .doc(eventId) // Validated non-empty string path.
                    .get(),
                builder: (context, eventSnapshot) {
                  // Show a small loader within the list item while fetching details.
                  if (!eventSnapshot.hasData) {
                    return const SizedBox(
                      height: 50,
                      child: Center(child: LinearProgressIndicator()),
                    );
                  }

                  final eventData =
                      eventSnapshot.data?.data() as Map<String, dynamic>?;

                  // Defensive check: If the event document no longer exists in Firestore.
                  if (eventData == null) {
                    return const SizedBox.shrink(); 
                  }

                  // Resolve bilingual text (Arabic/English) based on the app's current locale.
                  String title = BilingualHelper.getText(eventData['Title'], context);
                  if (title.isEmpty) {
                    title = AppLocalizations.of(context).unknownEvent;
                  }

                  String subtitle = BilingualHelper.getText(eventData['Schedule'], context);
                  if (subtitle.isEmpty) {
                    subtitle = AppLocalizations.of(context).scheduleNotSet;
                  }

                  return Card(
                    elevation: 0, // Flat design consistent with the matte theme.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight, 
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event,
                          color: AppColors.primary, 
                        ),
                      ),
                      title: Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain, 
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ), 
                      ),
                      trailing: const Icon(
                        Icons.notifications,
                        color: AppColors.primary, 
                      ),
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