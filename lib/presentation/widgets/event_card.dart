import 'package:flutter/material.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/theme.dart'; // Imports the centralized theme for consistent styling across the app.

/// A highly reusable UI component that displays detailed information about a specific event or stop.
///
/// The [EventCard] is split into a two-column layout:
/// - **Left Column:** Displays the event image and interactive action buttons (Favorite, Notify, Comment, Attend).
/// - **Right Column:** Displays the textual data (Title, Description, Schedule, Price, Crowd Status, and Map Route).
class EventCard extends StatelessWidget {
  /// The primary name of the event.
  final String title;

  /// The network URL for the event's cover image.
  final String imagePath;

  /// A brief summary or AI-generated reasoning for why this event was selected.
  final String description;

  /// The formatted time/duration string (e.g., "60 Mins" or "9:00 AM - 10:00 AM").
  final String schedule;

  /// The price display component.
  /// Passed as a [Widget] rather than a String to support complex layouts,
  /// such as inline custom image assets (e.g., the Saudi Riyal symbol).
  final Widget price;

  /// The current AI-estimated crowd level ("LOW", "MEDIUM", or "HIGH").
  final String crowdStatus;

  // --- INTERACTIVE CALLBACKS ---

  /// Triggered when the user taps the heart icon.
  final VoidCallback? onLike;

  /// Triggered when the user taps the bell icon.
  final VoidCallback? onNotification;

  /// Triggered when the user taps the chat bubble icon.
  final VoidCallback? onComment;

  /// Triggered when the user taps the map icon in the bottom right corner.
  /// Usually handles routing to native mapping apps (Google/Apple Maps).
  final VoidCallback onSuggestRoute;

  /// Creates an [EventCard].
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
    final loc = context.loc;

    return Container(
      // Margin to separate multiple cards in a list
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Soft shadow for a floating, modern aesthetic
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // IntrinsicHeight forces the Row's children to match the height of the tallest child.
      // This is crucial for making the VerticalDivider span the entire height of the card.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- LEFT COLUMN: Image & Quick Actions ---
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Event Image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Graceful fallback if the image URL is broken or missing
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImageError(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row of small interactive icons
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

                  // Primary Call-to-Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {}, // Attendance action is handled later.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        loc.imAttending,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CENTER DIVIDER ---
            const VerticalDivider(
              thickness: 1,
              width: 30,
              color: AppColors.divider,
            ),

            // --- RIGHT COLUMN: Information & Details ---
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Event Title
                  Text(
                    title,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // About Section Header
                  Text(
                    loc.about,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  // Description / Reasoning Text
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

                  // Details Section Header
                  Text(
                    loc.details,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  // Schedule Information
                  _buildDetailRow("${loc.schedule}:", schedule),

                  // Price Information (Handles the custom Widget row)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${loc.price}: ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textMain,
                          ),
                        ),
                        price,
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // AI Crowd Estimation Chip
                  _buildCrowdRow(context, crowdStatus),

                  // Spacer pushes the map icon to the very bottom right of the column
                  const Spacer(),

                  // Route Suggestion Button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: onSuggestRoute,
                      icon: const Icon(
                        Icons.map_outlined,
                        color: AppColors.primary,
                      ),
                      tooltip: loc.suggestRoute,
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

  /// Helper method to construct the small circular action icons (like, notify, comment).
  ///
  /// Wraps the icon in an [InkWell] to provide material ripple effects upon tapping.
  Widget _buildIconButton(IconData icon, VoidCallback? action) {
    return InkWell(
      onTap: action,
      child: Icon(icon, size: 22, color: AppColors.iconGrey),
    );
  }

  /// Helper method to build a visually distinct chip representing the crowd status.
  ///
  /// Color coding logic:
  /// - LOW: Green
  /// - MEDIUM: Orange
  /// - HIGH (or any other value): Red
  Widget _buildCrowdRow(BuildContext context, String status) {
    final normalizedStatus = status.trim().toUpperCase();
    final isLow = normalizedStatus == "LOW" || status.contains('منخفض');
    final isMedium = normalizedStatus == "MEDIUM" || status.contains('متوسط');
    final isHigh = normalizedStatus == "HIGH" || status.contains('عال');
    final statusColor = isLow
        ? Colors.green
        : (isMedium ? Colors.orange : Colors.red);
    final localizedStatus = isLow
        ? context.loc.low
        : (isMedium || isHigh
              ? (isMedium ? context.loc.medium : context.loc.high)
              : status);

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
            localizedStatus,
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

  /// Helper method to build a standard text row for basic details (e.g., Schedule).
  ///
  /// Uses [RichText] to make the label bold while keeping the value normal weight.
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

  /// Provides a safe fallback UI if the `imagePath` URL fails to load or is invalid.
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
