import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../application/services/location_service.dart';
import '../widgets/event_card.dart';
import '../../data/datasources/ai_remote_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class RouteSuggestionScreen extends StatefulWidget {
  const RouteSuggestionScreen({super.key});

  @override
  State<RouteSuggestionScreen> createState() => _RouteSuggestionScreenState();
}

class _RouteSuggestionScreenState extends State<RouteSuggestionScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = false;
  Map<String, dynamic>? _generatedTour;
  String? _errorMessage;

  // --- USER INPUT STATE ---
  final List<String> _selectedVibes = ['Museums'];
  double _availableHours = 4.0;
  String _startTime = "18:00";

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Museums', 'icon': Icons.museum},
    {'name': 'Heritage and Tradition', 'icon': Icons.history_edu},
    {'name': 'Libraries', 'icon': Icons.local_library},
    {'name': 'Conferences and Forums', 'icon': Icons.groups},
    {'name': 'Cultural Institutions', 'icon': Icons.domain},
    {'name': 'Exhibition and Convention Centre', 'icon': Icons.storefront},
  ];

  // --- INTERACTIVE PICKER METHODS ---
  bool _checkLoginAndShowMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("يرجى تسجيل الدخول للتفاعل مع الفعاليات"),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "دخول",
            textColor: Colors.white,
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

  Future<void> _selectStartTime() async {
    // Parse current string (e.g., "18:00") into integers for the picker
    int initialHour = int.tryParse(_startTime.split(":")[0]) ?? 18;
    int initialMinute = int.tryParse(_startTime.split(":")[1]) ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final String hour = picked.hour.toString().padLeft(2, '0');
        final String minute = picked.minute.toString().padLeft(2, '0');
        _startTime = "$hour:$minute";
      });
    }
  }

  void _selectDuration() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Select Tour Duration",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    int hours = index + 1;
                    return ListTile(
                      title: Text(
                        "$hours Hours",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        setState(() {
                          _availableHours = hours.toDouble();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateAiTour() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Position? pos = await LocationService.getCurrentLocation();

      final tourData = await AiRemoteSource().generateSmartTour(
        lat: pos?.latitude ?? 24.7136,
        lng: pos?.longitude ?? 46.6753,
        availableHours: _availableHours,
        preferences: _selectedVibes.join(", "),
        startTime: _startTime,
      );

      setState(() {
        _generatedTour = tourData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Could not generate tour. Please try again.";
        _isLoading = false;
      });
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedVibes.contains(category)) {
        _selectedVibes.remove(category);
      } else {
        _selectedVibes.add(category);
      }
    });
  }

  // --- UI RENDERERS ---

  Widget _buildCategoryChip(String label, IconData icon) {
    bool isSelected = _selectedVibes.contains(label);
    return GestureDetector(
      onTap: () => _toggleCategory(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.iconGrey,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textMain,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the input form before the AI generates the tour
  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Design your perfect evening",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          "What are you in the mood for?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories
              .map((cat) => _buildCategoryChip(cat['name'], cat['icon']))
              .toList(),
        ),

        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- INTERACTIVE START TIME BOX ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Start Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: _selectStartTime,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startTime,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),

            // --- INTERACTIVE DURATION BOX ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: _selectDuration,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_availableHours.toInt()} Hours",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiTimeline() {
    final stops = _generatedTour!['stops'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _generatedTour!['tour_title'] ?? "Your Custom Tour",
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 5),
        Text(
          "Estimated time: ${_generatedTour!['total_estimated_hours']} hours",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 30),

        ...stops.asMap().entries.map((entry) {
          int index = entry.key;
          var stop = entry.value;
          bool isLast = index == stops.length - 1;

          return IntrinsicHeight(
            // يضمن أن الخط يمتد حسب طول الكارد تلقائياً
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // التوقيت والخط العمودي
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      Text(
                        stop['arrival_time'] ?? "--:--",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: 2,
                          // يتوقف الخط عند آخر عنصر
                          color: isLast
                              ? Colors.transparent
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // الكارد الخاص بالفعالية
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 25,
                    ), // مسافة بين الكروت
                    child: EventCard(
                      title: stop['title'] ?? 'Event',
                      imagePath:
                          stop['image'] ??
                          stop['Image'] ??
                          "https://placehold.co/400x300/png?text=Wasel+AI",
                      description: stop['reasoning'] ?? 'AI Selected Path',
                      schedule: "${stop['duration_minutes'] ?? 0} Mins",
                      price: "Tour Included",
                      crowdStatus:
                          stop['crowd_status'] ??
                          "MEDIUM", // ربط حالة الزحام من الـ AI
                      onLike: () {
                        if (_checkLoginAndShowMessage()) {
                          // كود الحفظ في المفضلة
                        }
                      },
                      onSuggestRoute: () {
                        // هنا نضع كود فتح الخريطة بالإحداثيات
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
        title: const Text(
          "AI Route Generator",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 100),
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 20),
                          Text(
                            "Wasel AI is calculating traffic and crafting your perfect tour...",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : (_generatedTour == null)
                  ? _buildInputForm()
                  : _buildAiTimeline(),
            ),
          ),

          if (_generatedTour == null && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _generateAiTour,
                  child: const Text(
                    'Generate Smart Route',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          if (_generatedTour != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => setState(() => _generatedTour = null),
                  child: const Text(
                    'Start Over',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
