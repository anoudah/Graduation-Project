import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // sample data for notifications, in a real app this would come from a backend or local storage
    // create two notifications for events that were previously added
    // (matching the reminders list from RemindersScreen)
    final notifications = [
      {
        'title': 'Event Reminder: Saudi International Handcrafts Week',
        'subtitle': 'Banan event is happening in two days.',
      },
      {
        'title': 'Event Reminder: Diriyah Season',
        'subtitle': 'Occurs in 7 days.',
      },
      // other generic notifications can follow as needed
      {
        'title': 'Profile Update',
        'subtitle': 'Your profile was successfully updated.',
      },
      {
        'title': 'Reminder Sent',
        'subtitle': 'A reminder for your saved event was sent.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF6B4B8A),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
              title: Text(item['title']!),
              subtitle: Text(item['subtitle']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}
