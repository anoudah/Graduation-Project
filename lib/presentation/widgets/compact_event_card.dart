import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../screens/event_details_screen.dart';

class CompactEventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final bool isFullWidth;

  const CompactEventCard({
    super.key,
    required this.eventData,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = eventData['Image_Url'] ?? '';
    if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
      imageUrl = 'https://placehold.co/400x300/png?text=Culture+Event';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventData: eventData),
          ),
        );
      },
      child: Container(
        width: isFullWidth ? double.infinity : 220,
        margin: EdgeInsets.only(right: isFullWidth ? 0 : 16),
        height: isFullWidth ? 140 : 250,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // التحديث لحل تحذير الصورة image_3bd33b.jpg
              color: AppColors.textMain.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isFullWidth
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImage(imageUrl, true),
                  Expanded(child: _buildTextContent()),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(imageUrl, false),
                  Expanded(child: _buildTextContent()),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String url, bool isRow) {
    return ClipRRect(
      borderRadius: isRow
          ? const BorderRadius.horizontal(left: Radius.circular(16))
          : const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        url,
        width: isRow ? 140 : double.infinity,
        height: isRow ? double.infinity : 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: isRow ? 140 : double.infinity,
          height: isRow ? double.infinity : 140,
          color: AppColors.avatarBg,
          child: const Icon(
            Icons.image_not_supported,
            color: AppColors.iconGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    // معالجة السعر ليعرض Free إذا كان 0 أو null
    final priceValue = eventData['Price'];
    final priceDisplay =
        (priceValue == null || priceValue == 0 || priceValue == "0")
        ? 'Free'
        : '$priceValue SAR';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventData['Title'] ?? 'Unknown Event',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            eventData['Category'] ?? 'General',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                priceDisplay,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${eventData['Rating'] ?? 4.0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
