import 'package:flutter/material.dart';
import '../../core/theme.dart'; // استيراد الثيم لتوحيد الألوان

class EventCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final String schedule;
  final String price;
  final String crowdStatus;

  // الأزرار التفاعلية
  final VoidCallback? onLike;
  final VoidCallback? onNotification;
  final VoidCallback? onComment;
  final VoidCallback onSuggestRoute;

  const EventCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.schedule,
    required this.price,
    required this.crowdStatus,
    required this.onSuggestRoute,
    this.onLike,
    this.onNotification,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ), // إضافة هامش بسيط بين الكروت
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
        // يضمن أن الفاصل العمودي يأخذ كامل الطول المتاح
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // القسم الأيسر: الصورة والأزرار
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIconButton(Icons.favorite_border, onLike),
                      _buildIconButton(
                        Icons.notifications_none,
                        onNotification,
                      ),
                      _buildIconButton(Icons.comment_outlined, onComment),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "I'm attending",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(
              thickness: 1,
              width: 30,
              color: AppColors.divider,
            ),

            // القسم الأيمن: المعلومات
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildDetailRow("Schedule:", schedule),
                  _buildDetailRow("Price:", price),
                  const SizedBox(height: 8),
                  _buildCrowdRow(crowdStatus),
                  const Spacer(), // يدفع زر الموقع للأسفل
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: onSuggestRoute,
                      icon: const Icon(
                        Icons.map_outlined,
                        color: AppColors.primary,
                      ),
                      tooltip: "Suggest a route",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود مساعدة لبناء أيقونات الأكشنز
  Widget _buildIconButton(IconData icon, VoidCallback? action) {
    return InkWell(
      onTap: action,
      child: Icon(icon, size: 22, color: AppColors.iconGrey),
    );
  }

  // ميثود لعرض حالة الزحام
  Widget _buildCrowdRow(String status) {
    Color statusColor = status == "LOW"
        ? Colors.green
        : (status == "MEDIUM" ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 14, color: AppColors.textMain),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 180,
      color: AppColors.avatarBg,
      child: const Center(
        child: Icon(Icons.museum, size: 40, color: AppColors.iconGrey),
      ),
    );
  }
}
