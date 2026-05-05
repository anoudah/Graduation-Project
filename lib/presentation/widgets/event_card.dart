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

    // --- 1. استخراج المعرفات لضمان الربط الصحيح ---

    // --- 2. استخراج البيانات (مع معالجة الحروف الكبيرة والصغيرة) ---
    // جربنا كل المسميات المحتملة عشان ما يختفي التايتل زي الصورة
    final String title = BilingualHelper.getText(
      eventData['Title'] ?? '',
      context,
    );

    final String description = BilingualHelper.getText(
      eventData['About'] ?? '',
      context,
    );

    final String imagePath = eventData['Image_Url'] ?? "";

    final dynamic rawPrice = eventData['Price'] ?? eventData['price'] ?? '0';
    final String priceText = rawPrice is Map
        ? BilingualHelper.getText(rawPrice, context)
        : rawPrice.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- الجهة اليسرى: الصورة ---
              Expanded(
                flex: 4, // أعطينا الصورة مساحة ثابتة
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          height: 140, // تقليل الارتفاع ليتناسب مع الكارد
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImageError(),
                        )
                      : _buildImageError(),
                ),
              ),

              const VerticalDivider(
                thickness: 1,
                width: 25,
                color: AppColors.divider,
              ),

              // --- الجهة اليمنى: المعلومات ---
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.about,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Divider(height: 15, thickness: 0.5),
                    Row(
                      children: [
                        Text(
                          "${loc.price}: ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(priceText, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // أيقونة الخريطة
                        InkWell(
                          onTap: onSuggestRoute,
                          child: const Icon(
                            Icons.map_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        // زر See More
                        InkWell(
                          onTap: onTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "See More",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
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
      height: 140,
      color: AppColors.avatarBg,
      child: const Center(
        child: Icon(Icons.image, size: 30, color: AppColors.iconGrey),
      ),
    );
  }
}
