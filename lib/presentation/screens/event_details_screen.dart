import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../../application/services/location_service.dart'; 

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const EventDetailsScreen({super.key, required this.eventData});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFavorite = false;
  bool isReminder = false;
  bool isAttending = false;
  double userRating = 5.0;
  String selectedCrowd = 'Low';
  TextEditingController commentController = TextEditingController();

  // 1. فنكشن التأكد من تسجيل الدخول (ما لمستها)
  bool _checkLoginAndShowMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please log in to interact"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "Login",
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

  // 2. فنكشن التفاعل مع الفايربيس (حفظ البيانات - ما لمستها)
  Future<void> _updateInteraction(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String eventId = widget.eventData['id'] ?? '';
    if (eventId.isEmpty) return;

    String docId = "${user.uid}_$eventId";

    try {
      await FirebaseFirestore.instance
          .collection('User_Interactions')
          .doc(docId)
          .set({
            'User_Id': user.uid,
            'id': eventId,
            field: value,
            'Last_Update': Timestamp.now(),
          }, SetOptions(merge: true));

      if (field == 'Is_Attending') {
        await FirebaseFirestore.instance
            .collection('Events')
            .doc(eventId)
            .update({
              'attendance_count': value
                  ? FieldValue.increment(1)
                  : FieldValue.increment(-1),
            });
      }
    } catch (e) {
      print("Error updating interaction: $e");
    }
  }

  // 3. فنكشن إرسال التعليق (ما لمستها)
  Future<void> _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String eventId = widget.eventData['id'] ?? '';
    if (commentController.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('Reviews').add({
        'Event_Id': eventId,
        'User_Name': user.displayName ?? 'Anonymous',
        'Comment': commentController.text,
        'Rating': userRating,
        'Crowd_Level': selectedCrowd,
        'Timestamp': Timestamp.now(),
      });
      commentController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error submitting comment: $e");
    }
  }

  // 4. واجهة كتابة التعليق (BottomSheet - ما لمستها)
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
              const Text(
                "Write a Review",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              // تقييم النجوم
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
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submitComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to make dates look premium (e.g., "Apr 6")
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}";
  }
  // Helper to make times look premium (e.g., "9:30 AM")
  String _formatTime(DateTime date) {
    int hour = date.hour;
    int minute = date.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    
    hour = hour % 12;
    if (hour == 0) hour = 12; // Handles midnight and noon
    
    String minuteStr = minute < 10 ? '0$minute' : '$minute';
    return "$hour:$minuteStr $ampm";
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.eventData;

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
          data['Category'] ?? "Details",
          style: const TextStyle(color: AppColors.textMain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                  _buildAboutSection(data),
                  const SizedBox(height: 30),
                  _buildDetailsGrid(data),
                  const SizedBox(height: 40),
                  _buildReviewsSection(data['id'] ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets البناء (كلها مرتبطة بالثيم) ---

  Widget _buildHeaderImage(Map<String, dynamic> data) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(data['Image_Url'] ?? ''),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMainTitle(Map<String, dynamic> data) {
    return Text(
      data['Title'] ?? "No Title",
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildActionButtons() {
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
            isAttending ? "Attending" : "I'm attending",
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 26),
      onPressed: onTap,
    );
  }

  Widget _buildAboutSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          data['About'] ?? "No description.",
          style: const TextStyle(
            color: AppColors.textMain,
            height: 1.5,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(Map<String, dynamic> data) {
    // --- BEAUTIFUL DATE FORMATTER ---
    String scheduleText = "To Be Announced";
    try {
      // --- THE MANUAL OVERRIDE (For complex or weird schedules) ---
      // If the database has a specific text string for 'Schedule', we trust it blindly and skip the math!
      if (data['Schedule'] != null && data['Schedule'].toString().trim().isNotEmpty) {
        // We replace '\\n' so you can actually type line breaks directly into the Firebase console!
        scheduleText = data['Schedule'].toString().replaceAll('\\n', '\n');
      } 
      // --- NORMAL AUTOMATIC MATH (For standard events) ---
      else {
        var start = data['start_time'] ?? data['Start_Time'] ?? data['start'];
        var end = data['end_time'] ?? data['End_Time'] ?? data['end'];

        // --- SCENARIO 1: Native Firebase Timestamps ---
        if (start != null && start is Timestamp) {
          DateTime startDate = start.toDate();
          String startTime = _formatTime(startDate);
          
          if (end is Timestamp) {
            DateTime endDate = end.toDate();
            String endTime = _formatTime(endDate);
            
            if (startDate.day != endDate.day || startDate.month != endDate.month) {
               if (startTime == endTime) {
                 scheduleText = "${_formatDate(startDate)} - ${_formatDate(endDate)}, ${startDate.year}\n$startTime everyday";
               } else {
                 scheduleText = "${_formatDate(startDate)} - ${_formatDate(endDate)}, ${startDate.year}\n$startTime - $endTime everyday";
               }
            } else {
               scheduleText = "${_formatDate(startDate)}, ${startDate.year}\n$startTime — $endTime";
            }
          } else {
            scheduleText = "${_formatDate(startDate)}, ${startDate.year}\n$startTime";
          }
        } 
        // --- SCENARIO 2: Python/FastAPI ISO Strings ---
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
                
                if (parsedStart.day != parsedEnd.day || parsedStart.month != parsedEnd.month) {
                   if (startTime == endTime) {
                     scheduleText = "${_formatDate(parsedStart)} - ${_formatDate(parsedEnd)}, ${parsedStart.year}\n$startTime everyday";
                   } else {
                     scheduleText = "${_formatDate(parsedStart)} - ${_formatDate(parsedEnd)}, ${parsedStart.year}\n$startTime - $endTime everyday";
                   }
                } else {
                   scheduleText = "${_formatDate(parsedStart)}, ${parsedStart.year}\n$startTime — $endTime";
                }
              } else {
                 scheduleText = "${_formatDate(parsedStart)}, ${parsedStart.year}\n$startTime";
              }
            } else {
              scheduleText = "${_formatDate(parsedStart)}, ${parsedStart.year}\n$startTime";
            }
          } else {
            scheduleText = start.split('T').first; 
          }
        }
      }
    } catch (e) {
      debugPrint("WASEL SCHEDULE PARSING ERROR: $e");
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Soft matte shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Using the new Premium Rows!
          _premiumDetailRow(Icons.calendar_today, "Date & Time", scheduleText),
          const SizedBox(height: 16), // Replaced dividers with clean spacing
          
          _premiumDetailRow(Icons.confirmation_number_outlined, "Ticket Price", data['Price']?.toString() ?? "Free Entry"),
          const SizedBox(height: 16),
          
          _premiumDetailRow(Icons.location_on_outlined, "Location", data['Location_Address'] ?? "Riyadh"),
          
          const SizedBox(height: 24),
          
          // --- FULL-WIDTH NAVIGATE BUTTON ---
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
                    var fallbackLat = data['latitude'] ?? data['targetLat'] ?? data['Latitude'];
                    var fallbackLng = data['longitude'] ?? data['targetLng'] ?? data['Longitude'];
                    if (fallbackLat != null && fallbackLng != null) {
                      targetLat = double.tryParse(fallbackLat.toString()) ?? 24.7136;
                      targetLng = double.tryParse(fallbackLng.toString()) ?? 46.6753;
                    }
                  }
                } catch (e) {
                  debugPrint("WASEL DETAILS PARSING ERROR: $e");
                }
                LocationService.openMapRoute(targetLat, targetLng);
              },
              icon: const Icon(Icons.directions, color: AppColors.primary),
              label: const Text(
                "Navigate to Event",
                style: TextStyle(
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

  // Modern App Store style data rows
  Widget _premiumDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        // Soft colored container for the icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        
        // Stacked text
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

  Widget _buildReviewsSection(String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 15),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Reviews')
              .where('Event_Id', isEqualTo: eventId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            return Column(
              children: snapshot.data!.docs
                  .map(
                    (doc) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          doc['User_Name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(doc['Comment']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(doc['Rating'].toString()),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
