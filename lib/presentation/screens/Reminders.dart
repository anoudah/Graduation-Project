import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminders = [
      {
        'title': 'Saudi International Handcrafts Week (Banan)',
        'subtitle': 'Coming up in two days',
      },
      {
        'title': 'Diriyah Season',
        'subtitle': 'Coming up in 7 days',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reminders'),
        backgroundColor: const Color(0xFF6B4B8A),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = reminders[index];
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
                child: const Icon(Icons.event, color: Colors.white),
              ),
              title: Text(item['title']!),
              subtitle: Text(item['subtitle']!),
              trailing: const Icon(Icons.notifications),
            ),
          );
        },
      ),
    );
  }
}
 