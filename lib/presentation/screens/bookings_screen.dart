import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils/bilingual_helper.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to see your bookings'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User_Bookings')
                  .where('User_Id', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No bookings yet'));
                }

                final bookings = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['Booked_At'];
                    final bTime = bData['Booked_At'];

                    if (aTime is Timestamp && bTime is Timestamp) {
                      return bTime.toDate().compareTo(aTime.toDate());
                    }
                    return 0;
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final data = bookings[index].data() as Map<String, dynamic>;
                    final title = BilingualHelper.getText(
                      data['Title'],
                      context,
                    );
                    final location = BilingualHelper.getText(
                      data['Location_Address'],
                      context,
                    );
                    final schedule = BilingualHelper.getText(
                      data['Schedule'],
                      context,
                    );
                    final rawPrice = BilingualHelper.getText(
                      data['Price'],
                      context,
                    );
                    final imageUrl = BilingualHelper.getText(
                      data['Image_Url'],
                      context,
                    );
                    final paymentMethod =
                        data['Payment_Method']?.toString() ?? 'Payment';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imageUrl.isEmpty
                                  ? _buildImageFallback()
                                  : Image.network(
                                      imageUrl,
                                      width: 86,
                                      height: 86,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _buildImageFallback(),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isEmpty ? 'Booked Event' : title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textMain,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (schedule.isNotEmpty)
                                    _buildInfoRow(
                                      Icons.calendar_today_outlined,
                                      schedule,
                                    ),
                                  if (location.isNotEmpty)
                                    _buildInfoRow(
                                      Icons.location_on_outlined,
                                      location,
                                    ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildChip('Confirmed', Colors.green),
                                      _buildChip(
                                        paymentMethod,
                                        AppColors.primary,
                                      ),
                                      if (rawPrice.isNotEmpty)
                                        _buildChip(
                                          '$rawPrice SAR',
                                          Colors.black87,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  static Widget _buildImageFallback() {
    return Container(
      width: 86,
      height: 86,
      color: AppColors.avatarBg,
      child: const Icon(Icons.confirmation_number, color: AppColors.primary),
    );
  }

  static Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
