import 'package:flutter/material.dart';
import '../../core/theme.dart'; 

class CompactEventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final bool isFullWidth;

  const CompactEventCard({
    Key? key, 
    required this.eventData, 
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = eventData['Image_Url'] ?? '';
    if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
      imageUrl = 'https://placehold.co/400x300/png?text=Culture+Event';
    }

    // We extract the text section into a separate widget so we don't have to write it twice!
    Widget buildTextContent() {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventData['Title'] ?? 'Unknown Event',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
              maxLines: isFullWidth ? 2 : 1, // Gives more room for the title in List View
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              eventData['Category'] ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary, 
                fontSize: 12,
                fontFamily: 'Poppins', 
              ),
            ),
            const Spacer(), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  eventData['Price'] != null ? '${eventData['Price']}' : 'Free',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${eventData['Rating'] ?? 4.0}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      );
    }

    return Container(
      width: isFullWidth ? double.infinity : 220, 
      margin: EdgeInsets.only(right: isFullWidth ? 0 : 16),
      // SHORTER HEIGHT for the list view so it looks like a neat banner
      height: isFullWidth ? 140 : 250, 
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withOpacity(0.1), 
            blurRadius: 8, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      // SMART LAYOUT: Row for List View, Column for Grid View
      child: isFullWidth 
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LHS: Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    width: 140, // Locks the image to a perfect square on the left
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      color: AppColors.avatarBg,
                      child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.iconGrey)),
                    ),
                  ),
                ),
                // RHS: Info
                Expanded(child: buildTextContent()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP: Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    height: 140, 
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: AppColors.avatarBg,
                      child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.iconGrey)),
                    ),
                  ),
                ),
                // BOTTOM: Info
                Expanded(child: buildTextContent()),
              ],
            ),
    );
  }
}