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
    final localizations = AppLocalizations.of(context);

    // Retrieves the unique ID of the currently authenticated Firebase user, or null if guest.
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          localizations.yourReminders,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      // --- EXACTLY LIKE FAVORITES: Simple centered text for guests ---
      body: currentUserId == null
          ? Center(child: Text(localizations.pleaseLoginFirst))
          : StreamBuilder<QuerySnapshot>(
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
                    child: Text(localizations.noRemindersCurrently),
                  );
                }

                final reminderDocs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reminderDocs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // Extract the individual interaction document.
                    final interaction =
                        reminderDocs[index].data() as Map<String, dynamic>;

                    // Extract and validate the event ID
                    final String eventId = interaction['id'] ?? '';

                    if (eventId.isEmpty) {
                      return const SizedBox.shrink(); // Silently skip broken database records.
                    }

                    // --- DATA LAYER: Event Details Fetch ---
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Events')
                          .doc(eventId)
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

                        // Resolve bilingual text
                        String title = BilingualHelper.getText(
                          eventData['Title'],
                          context,
                        );
                        if (title.isEmpty) {
                          title = localizations.unknownEvent;
                        }

                        // 1. نحاول جلب النص من حقل Schedule أولاً
                        String scheduleFromDb = BilingualHelper.getText(
                          eventData['Schedule'],
                          context,
                        );

                        // ... سطر 113 (نهاية تعريف scheduleFromDb)

                        // 2. إذا كان فارغاً، نتحقق من نوع البيانات ونعرض التاريخ فقط
                        String subtitle = scheduleFromDb;

                        if (subtitle.isEmpty) {
                          final rawDate = eventData['start_time'];
                          if (rawDate is Timestamp) {
                            // إذا كان Timestamp نحوله لتاريخ ونأخذ الجزء الأول منه
                            subtitle = rawDate
                                .toDate()
                                .toString()
                                .split(' ')
                                .first;
                          } else if (rawDate != null) {
                            // إذا كان نصاً عادياً
                            subtitle = rawDate.toString().split('T').first;
                          } else {
                            subtitle = localizations.scheduleNotSet;
                          }
                        }
                        // --- ORIGINAL LIST TILE UI --- (هذا السطر سيكون هو السطر التالي مباشرة)
                        // --- ORIGINAL LIST TILE UI ---
                        return Card(
                          elevation: 0,
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
