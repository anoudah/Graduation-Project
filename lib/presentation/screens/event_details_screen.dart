import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../../application/services/location_service.dart';
import 'payment_screen.dart';
import '../../core/utils/bilingual_helper.dart';

/// --- PRESENTATION LAYER ---
/// [EventDetailsScreen] acts as the deep-dive view for a specific event.
///
/// Responsibilities:
/// 1. Parse and display bilingual event data safely to prevent JSON mapping crashes.
/// 2. Handle user interactions (Favorites, Reminders, Attendance, and Reviews).
/// 3. Read and write real-time data to Firebase Firestore.
/// 4. Provide native routing intents to Google Maps/Apple Maps.
class EventDetailsScreen extends StatefulWidget {
  /// The raw event data payload passed from the previous screen (e.g., CategoryScreen).
  final Map<String, dynamic> eventData;

  /// The category id from the screen that opened this event, when available.
  final String? sourceCategoryId;

  const EventDetailsScreen({
    super.key,
    required this.eventData,
    this.sourceCategoryId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  // --- STATE VARIABLES ---
  // Tracks the interactive states of the event for the current user.
  bool isFavorite = false;
  bool isReminder = false;
  bool isAttending = false;
  bool isLoading = true;
  // State for the review/comment bottom sheet.
  double userRating = 5.0;
  String selectedCrowd = 'Low';
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // أول ما تفتح الصفحة نطلب البيانات فوراً
    _loadUserInteractions();
  }

  Future<void> _loadUserInteractions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    // تأكدي أن الـ ID هو نفسه المستخدم في الحفظ
    String eventId = widget.eventData['id'] ?? '';
    if (eventId.isEmpty) return;

    String docId = "${user.uid}_$eventId";

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('User_Interactions')
          .doc(docId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          // ملاحظة مهمة: تأكدي أن الحروف (F, R, I) كبيرة كما في الفايربيس
          isFavorite = doc['Favorite'] ?? false;
          isReminder = doc['Reminder'] ?? false;
          isAttending = doc['Is_Attending'] ?? false;
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("خطأ في جلب البيانات: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _normalizeForMatch(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  Iterable<String> _textValues(dynamic field) sync* {
    if (field == null) return;

    if (field is String) {
      yield field;
      return;
    }

    if (field is Map) {
      for (final value in field.values) {
        if (value != null) yield value.toString();
      }
      return;
    }

    yield field.toString();
  }

  bool get _isHeritageCategory {
    final categoryIds =
        [
              widget.sourceCategoryId,
              widget.eventData['Category_ID'],
              widget.eventData['Category_Id'],
              widget.eventData['categoryId'],
              widget.eventData['category_id'],
            ]
            .where((value) => value != null)
            .map((value) => value.toString().trim().toUpperCase());

    if (categoryIds.any((value) => value == 'HER')) return true;

    return _textValues(widget.eventData['Category']).any((value) {
      final normalized = _normalizeForMatch(value);
      return normalized.contains('heritage') &&
          normalized.contains('tradition');
    });
  }

  bool get _isDiriyahHistoricalTour {
    return _textValues(widget.eventData['Title']).any((value) {
      final normalized = _normalizeForMatch(value);
      final hasDiriyah =
          normalized.contains('diriyah') || normalized.contains('diriyadh');
      return hasDiriyah &&
          normalized.contains('historical') &&
          normalized.contains('tour');
    });
  }

  bool get _showBookingButton =>
      _isHeritageCategory && _isDiriyahHistoricalTour;

  /// Authentication Gatekeeper.
  ///
  /// Prevents anonymous users from modifying the database. If no user is logged in,
  /// it halts the action and prompts them to navigate to the [LoginScreen].
  bool _checkLoginAndShowMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final localizations = AppLocalizations.of(context);

      // 1. Instantly remove any stuck snackbars before showing a new one
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // 2. Show the new, auto-dismissing floating snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseLoginToInteract),
          behavior: SnackBarBehavior
              .floating, // Makes it hover instead of attaching to the bottom
          margin: const EdgeInsets.only(
            bottom: 20,
            left: 20,
            right: 20,
          ), // Gives it nice rounded breathing room
          backgroundColor: AppColors.primary,
          duration: const Duration(
            seconds: 3,
          ), // GUARANTEES it will vanish after 3 seconds
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10,
            ), // Matches your app's modern aesthetic
          ),
          action: SnackBarAction(
            label: localizations.login,
            textColor: AppColors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  /// Updates the user's interaction (Favorite, Reminder, Attending) in Firestore.
  ///
  /// Creates or merges a document in the `User_Interactions` collection using a
  /// composite ID (`userId_eventId`). If the user marks "Attending", it also
  /// increments/decrements the global `attendance_count` on the main Event document.
  Future<void> _updateInteraction(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String eventId = widget.eventData['id'] ?? '';
    if (eventId.isEmpty) return;

    String docId = "${user.uid}_$eventId";

    try {
      // 1. Update the user's personal interaction log
      await FirebaseFirestore.instance
          .collection('User_Interactions')
          .doc(docId)
          .set({
            'User_Id': user.uid,
            'id': eventId,
            field: value,
            'Last_Update': Timestamp.now(),
          }, SetOptions(merge: true));

      // 2. Update the global event statistics if attendance changed
      if (field == 'Is_Attending') {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .update({
              // CHANGED HERE: Match the Python AI exactly ("attending_count")
              'attending_count': value
                  ? FieldValue.increment(1)
                  : FieldValue.increment(-1),
            });
      }
    } catch (e) {
      debugPrint("Error updating interaction: $e");
    }
  }

  /// Submits a user review and crowd report to the Firestore database.
  ///
  /// Writes the comment to the `Comment Feedback` collection and increments
  /// the respective crowd counter (Low, Medium, High) on the main Event document
  /// to feed data into the AI crowd estimation model.
  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    String eventId = widget.eventData['id'] ?? '';
    if (commentController.text.isEmpty) return;

    final successMessage = AppLocalizations.of(
      context,
    ).reviewSubmittedSuccessfully;

    try {
      // 1. جلب الاسم
      String finalName = "Wasel User";
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        finalName = userDoc['Full_Name'] ?? "Wasel User";
      }

      // 2. تخزين التعليق
      await FirebaseFirestore.instance.collection('Comment Feedback').add({
        'Comment_Text': commentController.text,
        'Date': Timestamp.now(),
        'Full_Name': finalName,
        'Rating': userRating.toInt(),
        'User_Id': user.uid,
        'crowd_report': selectedCrowd,
        'id': eventId,
      });

      // 3. تحديث عدادات الزحمة
      String crowdField = '';

      if (selectedCrowd == 'Low') {
        crowdField = 'report_low_count';
      } else if (selectedCrowd == 'Medium') {
        crowdField = 'report_medium_count';
      } else if (selectedCrowd == 'High') {
        crowdField = 'report_high_count';
      }
      if (crowdField.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .update({
              crowdField: FieldValue.increment(1),
              'Last_Feedback_Date': Timestamp.now(),
            });
      }

      // 4. التعديل المطلوب: تنظيف الحقل وإغلاق الشيت فقط
      commentController.clear();
      if (!mounted) return;

      // يغلق نافذة الكتابة فقط ويتركك في صفحة الفعالية
      Navigator.pop(context);

      // إظهار رسالة النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("DATABASE ERROR: $e");
    }
  }

  /// Displays an interactive BottomSheet allowing the user to write a review.
  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. عنوان "اكتب تعليق"
              Text(
                context.loc.writeComment,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: context.loc.shareYourExperience,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),

              // 2. عنوان "حالة الزحمة"
              Text(
                context.loc.crowdStatus,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              // استخدمنا Center و Row بدلاً من Wrap لتنسيق الخيارات في المنتصف
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Low', 'Medium', 'High'].map((level) {
                  String label = (level == 'Low')
                      ? context.loc.low
                      : (level == 'Medium')
                      ? context.loc.medium
                      : context.loc.high;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selectedCrowd == level,
                      // ignore: deprecated_member_use
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      onSelected: (bool selected) {
                        if (selected) {
                          setSheetState(() => selectedCrowd = level);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),

              // 3. إضافة عنوان "التقييم" فوق النجوم
              const Text(
                "Rate the Event",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 5),
              // نجوم التقييم التفاعلية
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < userRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () =>
                        setSheetState(() => userRating = index + 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. زر الإرسال
              ElevatedButton(
                onPressed: () async {
                  await _submitComment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.loc.submitReview,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to make raw DateTimes look premium (e.g., "Apr 6").
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.day}";
  }

  /// Helper to convert 24h DateTimes to readable 12h formats (e.g., "9:30 PM").
  String _formatTime(DateTime date) {
    int hour = date.hour;
    int minute = date.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    if (hour == 0) hour = 12;

    String minuteStr = minute < 10 ? '0$minute' : '$minute';
    return "$hour:$minuteStr $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.eventData;

    // UI SAFETY: Safely extract AppBar Category Title using the BilingualHelper.
    // This prevents the app from crashing if 'Category' is a Map instead of a String.
    String categoryTitle = BilingualHelper.getText(data['Category'], context);
    if (categoryTitle.isEmpty) categoryTitle = "Details";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryTitle,
          style: const TextStyle(color: AppColors.textMain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // =====================================================================
        // THE RESPONSIVE WEB FIX
        // Center the content and restrict it to an 800px max width so it
        // doesn't stretch infinitely on large web browser windows!
        // =====================================================================
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildHeaderImage(data),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainTitle(data),
                      const SizedBox(height: 20),
                      _buildActionButtons(context),
                      const SizedBox(height: 30),
                      _buildAboutSection(data, context),
                      const SizedBox(height: 30),
                      _buildDetailsGrid(data, context),
                      const SizedBox(height: 40),
                      _buildReviewsSection(data['id'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the large cover image for the event.
  Widget _buildHeaderImage(Map<String, dynamic> data) {
    // ASSET SAFETY: Checks multiple DB keys for the image.
    // It also intercepts known bad CORS domains (via.placeholder.com) and swaps
    // them with safe alternatives to prevent Flutter Web CanvasKit crashes.
    String imageUrl = BilingualHelper.getText(
      data['Image_Url'] ?? data['image'] ?? data['Image'],
      context,
    );
    if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
      imageUrl = 'https://placehold.co/400x300/png?text=Culture+Event';
    }

    return Padding(
      // Adds space so the image doesn't touch the very edges of the screen
      padding: const EdgeInsets.all(16.0), 
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.avatarBg,
          // THE KEY CHANGE: Rounded corners for a softer look
          borderRadius: BorderRadius.circular(20), 
          // Optional: A shadow makes the image "pop" off the page
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// Builds the primary title of the event safely handling bilingual maps.
  Widget _buildMainTitle(Map<String, dynamic> data) {
    String title = BilingualHelper.getText(data['Title'], context);
    if (title.isEmpty) title = "Unknown Event";

    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
  }

  /// Renders the interactive row of action buttons (Like, Notify, Comment, Attend).
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _iconBtn(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          isFavorite ? Colors.red : AppColors.iconGrey,
          () {
            if (_checkLoginAndShowMessage()) {
              setState(() => isFavorite = !isFavorite);
              _updateInteraction('Favorite', isFavorite);
            }
          },
        ),
        _iconBtn(
          isReminder ? Icons.notifications : Icons.notifications_none,
          isReminder ? AppColors.primary : AppColors.iconGrey,
          () {
            if (_checkLoginAndShowMessage()) {
              setState(() => isReminder = !isReminder);
              _updateInteraction('Reminder', isReminder);
            }
          },
        ),
        _iconBtn(Icons.chat_bubble_outline, AppColors.iconGrey, () {
          if (_checkLoginAndShowMessage()) _showCommentsSheet();
        }),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_checkLoginAndShowMessage()) {
                  setState(() => isAttending = !isAttending);
                  _updateInteraction('Is_Attending', isAttending);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAttending ? Colors.green : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                isAttending ? context.loc.attending : context.loc.imAttending,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            const SizedBox(height: 8),
            if (_showBookingButton) ...[
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint("Book Now button tapped!");
                    if (_checkLoginAndShowMessage()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(eventData: widget.eventData),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    context.loc.bookNow,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Small UI helper for the circular action icons.
  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 26),
      onPressed: onTap,
    );
  }

  /// Renders the event description block, safely extracting bilingual text.
  Widget _buildAboutSection(Map<String, dynamic> data, BuildContext context) {
    String aboutText = BilingualHelper.getText(
      data['About'] ?? data['Description'],
      context,
    );
    if (aboutText.isEmpty) aboutText = "No description available.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.about,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          aboutText,
          style: const TextStyle(
            color: AppColors.textMain,
            height: 1.5,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// Builds the critical details block containing Schedule, Price, and Location logic.
  ///
  /// This method contains robust fallback logic. It attempts to parse native Firestore
  /// Timestamps, ISO Strings from the Python backend, and manual schedule strings.
  Widget _buildDetailsGrid(Map<String, dynamic> data, BuildContext context) {
    String scheduleText = "To Be Announced";
    try {
      // 1. SAFELY PARSE SCHEDULE
      // We check for a hardcoded string first, bypassing complex math if it exists.
      String rawSchedule = BilingualHelper.getText(data['Schedule'], context);

      if (rawSchedule.trim().isNotEmpty) {
        scheduleText = rawSchedule.replaceAll('\\n', '\n');
      } else {
        // Fallback: Calculate schedule from Start/End dates
        var start = data['start_time'] ?? data['Start_Time'] ?? data['start'];
        var end = data['end_time'] ?? data['End_Time'] ?? data['end'];

        // Handle Firestore Timestamp objects
        if (start != null && start is Timestamp) {
          DateTime startDate = start.toDate();
          String startTime = _formatTime(startDate);

          if (end is Timestamp) {
            DateTime endDate = end.toDate();
            String endTime = _formatTime(endDate);

            if (startDate.day != endDate.day ||
                startDate.month != endDate.month) {
              if (startTime == endTime) {
                scheduleText =
                    "${_formatDate(startDate)} - ${_formatDate(endDate)}, ${startDate.year}\n$startTime everyday";
              } else {
                scheduleText =
                    "${_formatDate(startDate)} - ${_formatDate(endDate)}, ${startDate.year}\n$startTime - $endTime everyday";
              }
            } else {
              scheduleText =
                  "${_formatDate(startDate)}, ${startDate.year}\n$startTime — $endTime";
            }
          } else {
            scheduleText =
                "${_formatDate(startDate)}, ${startDate.year}\n$startTime";
          }
        }
        // Handle Python backend ISO string formats
        else if (start is String) {
          DateTime? parsedStart = DateTime.tryParse(start);

          if (parsedStart != null) {
            parsedStart = parsedStart.toLocal();
            String startTime = _formatTime(parsedStart);

            if (end is String) {
              DateTime? parsedEnd = DateTime.tryParse(end);
              if (parsedEnd != null) {
                parsedEnd = parsedEnd.toLocal();
                String endTime = _formatTime(parsedEnd);

                if (parsedStart.day != parsedEnd.day ||
                    parsedStart.month != parsedEnd.month) {
                  if (startTime == endTime) {
                    scheduleText =
                        "${_formatDate(parsedStart)} - ${_formatDate(parsedEnd)}, ${parsedStart.year}\n$startTime everyday";
                  } else {
                    scheduleText =
                        "${_formatDate(parsedStart)} - ${_formatDate(parsedEnd)}, ${parsedStart.year}\n$startTime - $endTime everyday";
                  }
                } else {
                  scheduleText =
                      "${_formatDate(parsedStart)}, ${parsedStart.year}\n$startTime — $endTime";
                }
              } else {
                scheduleText =
                    "${_formatDate(parsedStart)}, ${parsedStart.year}\n$startTime";
              }
            } else {
              scheduleText =
                  "${_formatDate(parsedStart)}, ${parsedStart.year}\n$startTime";
            }
          } else {
            scheduleText = start.split('T').first;
          }
        }
      }
    } catch (e) {
      debugPrint("WASEL SCHEDULE PARSING ERROR: $e");
    }

    // 2. SAFELY PARSE BILINGUAL PRICE (Updated for Image Symbol)
    String rawPrice = BilingualHelper.getText(
      data['Price'] ?? data['price'],
      context,
    );
    bool isArabic = Directionality.of(context) == TextDirection.rtl;

    bool isFree = rawPrice.isEmpty || rawPrice == "0";
    String priceDisplay = isFree
        ? (isArabic ? 'مجاني' : 'Free Entry')
        : rawPrice;

    // Create a custom widget for the price if it's not free
    Widget? customPriceWidget;
    if (!isFree) {
      customPriceWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            priceDisplay,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/images/riyal_symbol.png',
            height: 12, // Scaled to match the fontSize 15
            color:
                AppColors.textMain, // Tints the symbol to match the detail text
            errorBuilder: (context, error, stackTrace) => const Text(
              ' SAR',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    // 3. SAFELY PARSE LOCATION NAME
    String locationAddress = BilingualHelper.getText(
      data['Location_Address'] ?? data['Location_Name'],
      context,
    );
    if (locationAddress.isEmpty) {
      locationAddress = isArabic ? "الرياض" : "Riyadh";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _premiumDetailRow(
            Icons.calendar_today,
            context.loc.dateAndTime,
            scheduleText,
          ),
          const SizedBox(height: 16),

          _premiumDetailRow(
            Icons.confirmation_number_outlined,
            context.loc.ticketPrice,
            priceDisplay,
            customValueWidget:
                customPriceWidget, // Pass our new image row here!
          ),
          const SizedBox(height: 16),

          _premiumDetailRow(
            Icons.location_on_outlined,
            context.loc.location,
            locationAddress,
          ),

          const SizedBox(height: 24),

          // --- FULL-WIDTH NAVIGATE BUTTON ---
          // Uses defensive coordinate parsing before handing off to native intents.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                double targetLat = 24.7136;
                double targetLng = 46.6753;

                try {
                  var geo = data['Location'] ?? data['location'];
                  if (geo != null && geo is GeoPoint) {
                    targetLat = geo.latitude;
                    targetLng = geo.longitude;
                  } else {
                    var fallbackLat =
                        data['latitude'] ??
                        data['targetLat'] ??
                        data['Latitude'];
                    var fallbackLng =
                        data['longitude'] ??
                        data['targetLng'] ??
                        data['Longitude'];
                    if (fallbackLat != null && fallbackLng != null) {
                      targetLat =
                          double.tryParse(fallbackLat.toString()) ?? 24.7136;
                      targetLng =
                          double.tryParse(fallbackLng.toString()) ?? 46.6753;
                    }
                  }
                } catch (e) {
                  debugPrint("WASEL DETAILS PARSING ERROR: $e");
                }
                // Trigger the device's native mapping application (Google/Apple Maps)
                LocationService.openMapRoute(targetLat, targetLng);
              },
              icon: const Icon(Icons.directions, color: AppColors.primary),
              label: Text(
                context.loc.navigateToEvent,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A highly reusable UI component for creating clean, icon-based info rows.
  /// Added [customValueWidget] to support injecting the custom PNG symbol.
  Widget _premiumDetailRow(
    IconData icon,
    String title,
    String value, {
    Widget? customValueWidget,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Use the custom widget if provided, otherwise default to standard Text
              customValueWidget ??
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  /// Binds a live Firestore stream to display user reviews for this specific event.
  Widget _buildReviewsSection(String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. عنوان القسم مترجم
        Text(
          context.loc.reviews,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Comment Feedback')
              .where('id', isEqualTo: eventId)
              .orderBy('Date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            // 2. رسالة "لا توجد تعليقات" مترجمة
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text(context.loc.noReviewsYet));
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                // 3. ترجمة حالة الزحمة ديناميكياً
                String crowdValue = doc['crowd_report'] ?? 'Low';
                String localizedCrowd;
                if (crowdValue == 'Low') {
                  localizedCrowd = context.loc.low;
                } else if (crowdValue == 'Medium') {
                  localizedCrowd = context.loc.medium;
                } else {
                  localizedCrowd = context.loc.high;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      doc['Full_Name'] ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc['Comment_Text'] ?? ''),
                        const SizedBox(height: 5),
                        // 4. دمج نص "حالة الزحمة" مع القيمة المترجمة
                        Text(
                          "${context.loc.crowdStatus}: $localizedCrowd",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text("${doc['Rating']} ⭐"),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
