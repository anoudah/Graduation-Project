import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../screens/event_details_screen.dart';
import '../../core/utils/bilingual_helper.dart';

/// A highly reusable and responsive UI component that displays an event's core details.
/// 
/// [CompactEventCard] supports two distinct visual layouts via the [isFullWidth] flag:
/// 1. A horizontal, row-based layout (ideal for vertical scrolling lists).
/// 2. A vertical, column-based layout (ideal for horizontal carousels).
/// 
/// This widget incorporates robust data extraction to prevent runtime crashes 
/// when interfacing with bilingual Firestore Maps.
class CompactEventCard extends StatelessWidget {
  /// The raw event data payload fetched from the Firestore database.
  final Map<String, dynamic> eventData;
  
  /// Determines the structural layout of the card. 
  /// Defaults to false (Column-based layout).
  final bool isFullWidth;
  
  /// The category id from the screen that opened this card, when available.
  final String? sourceCategoryId;

  const CompactEventCard({
    super.key,
    required this.eventData,
    this.isFullWidth = false,
    this.sourceCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ASSET RESOLUTION:
    // Safely attempts to extract the image URL. Checks multiple possible database keys.
    String imageUrl = BilingualHelper.getText(
      eventData['Image_Url'] ?? eventData['Image'], 
      context
    );
    
    // Fallback mechanism for empty URLs or placeholder artifacts.
    if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
      imageUrl = 'https://placehold.co/400x300/png?text=Culture+Event';
    }

    return InkWell(
      onTap: () {
        // State Transfer: Passes the resolved map to the detail screen for deep viewing.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventData: eventData,
              sourceCategoryId: sourceCategoryId,
            ),
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
            // Soft elevation shadow for depth
            BoxShadow(
              color: AppColors.textMain.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Dynamic Layout Generation based on the [isFullWidth] parameter.
        child: isFullWidth
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImage(imageUrl, true),
                  Expanded(child: _buildTextContent(context)), 
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(imageUrl, false),
                  Expanded(child: _buildTextContent(context)), 
                ],
              ),
      ),
    );
  }

  /// Constructs the visual thumbnail of the event.
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
        // Failsafe UI for broken network images to prevent layout collapse.
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

  /// Constructs the textual information block (Title, Category, Price, Rating).
  Widget _buildTextContent(BuildContext context) {
    // 2. FINANCIAL DATA FORMATTING:
    String rawPrice = BilingualHelper.getText(eventData['Price'] ?? eventData['price'], context);
    bool isArabic = Directionality.of(context) == TextDirection.rtl;
    
    // Check if the event is free
    bool isFree = rawPrice.isEmpty || rawPrice == "0";
    String priceDisplay = isFree ? (isArabic ? 'مجاني' : 'Free') : rawPrice;

    // 3. BILINGUAL TEXT EXTRACTION:
    String title = BilingualHelper.getText(eventData['Title'], context);
    if (title.isEmpty) title = isArabic ? 'حدث غير معروف' : 'Unknown Event';

    String category = BilingualHelper.getText(eventData['Category'], context);
    if (category.isEmpty) category = isArabic ? 'عام' : 'General';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Title
          Text(
            title, 
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Event Category
          Text(
            category, 
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          
          // Footer Row: Price & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PRICE COMPONENT WITH IMAGE SUPPORT
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The Number (or "Free" text)
                    Flexible(
                      child: Text(
                        priceDisplay,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Only show the image symbol if it is NOT free
                    if (!isFree) ...[
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/riyal_symbol.png',
                        height: 14,
                        color: AppColors.primary, // Tints the image to match your purple text
                        // Safe fallback in case you haven't added the image to your folders yet
                        errorBuilder: (context, error, stackTrace) => const Text(
                          ' SAR', 
                          style: TextStyle(
                            color: AppColors.primary, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // RATING COMPONENT
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
