import 'package:flutter/material.dart';
import 'package:wasel/core/utils/bilingual_helper.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/theme.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final VoidCallback onSuggestRoute;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.eventData,
    required this.onSuggestRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    // استخراج البيانات بناءً على صور الفايربيس حرفياً[cite: 5]
    final String title = BilingualHelper.getText(eventData['Title'], context);
    final String description = BilingualHelper.getText(
      eventData['About'],
      context,
    );
    final String imagePath = eventData['Image_Url'] ?? "";
    final String priceText = BilingualHelper.getText(
      eventData['Price'],
      context,
    );

    return GestureDetector(
      onTap: onTap, // الانتقال عند الضغط على الكرت كاملاً[cite: 5]
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imagePath,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageError(),
                  ),
                ),
              ),
              const VerticalDivider(
                thickness: 1,
                width: 30,
                color: AppColors.divider,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.about,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      "${loc.price}: $priceText",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: onSuggestRoute,
                          icon: const Icon(
                            Icons.map_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        // زر See More[cite: 4]
                        InkWell(
                          onTap: onTap,
                          child: Row(
                            children: [
                              Text(
                                "See More",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 180,
      color: AppColors.avatarBg,
      child: const Center(
        child: Icon(Icons.image, size: 40, color: AppColors.iconGrey),
      ),
    );
  }
}
