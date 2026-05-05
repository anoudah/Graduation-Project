import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../application/providers/language_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/theme.dart';
import '../../application/services/location_service.dart';
import '../../data/datasources/ai_remote_source.dart';
import 'smart_tour_screen.dart';

/// --- PRESENTATION LAYER ---
/// [RouteSuggestionScreen] acts as the primary input gateway for the AI Tour feature.
///
/// Responsibilities:
/// 1. Captures user preferences (Vibes/Categories, Start Time, and Duration).
/// 2. Manages the asynchronous loading state while the AI computes the route.
/// 3. Communicates with [LocationService] to append exact GPS coordinates to the request.
/// 4. Delegates the final rendering of the generated data to [SmartTourScreen].
class RouteSuggestionScreen extends StatefulWidget {
  final String? filterCategoryId; // Receives the category ID from the banner

  const RouteSuggestionScreen({super.key, this.filterCategoryId});

  @override
  State<RouteSuggestionScreen> createState() => _RouteSuggestionScreenState();
}

class _RouteSuggestionScreenState extends State<RouteSuggestionScreen> {
  // ===========================================================================
  // --- STATE MANAGEMENT ---
  // ===========================================================================

  /// Toggles the loading UI. Essential for preventing duplicate API calls
  /// while waiting for the AI response.
  bool _isLoading = false;

  /// Holds localized error messages to ensure smooth error recovery for the user.
  String? _errorMessage;

  // ===========================================================================
  // --- USER INPUT STATE ---
  // ===========================================================================

  /// Maintains the list of selected cultural categories. Defaults to 'Museums'
  /// unless overridden by the initState below.
  final List<String> _selectedVibes = ['Museums'];

  /// Determines the constraint for the AI's schedule generation.
  double _availableHours = 4.0;

  /// Formatted as HH:mm. Used by the AI to factor in venue operating hours and traffic.
  String _startTime = "18:00";

  /// The static taxonomy of cultural events available in Wasel.
  /// Values stay in English for backend compatibility; labels are localized in the UI.
  final List<Map<String, dynamic>> _categories = [
    {'value': 'Museums', 'icon': Icons.museum},
    {'value': 'Heritage and Tradition', 'icon': Icons.history_edu},
    {'value': 'Libraries', 'icon': Icons.local_library},
    {'value': 'Conferences and Forums', 'icon': Icons.groups},
    {'value': 'Cultural Institutions', 'icon': Icons.domain},
    {'value': 'Exhibition and Convention Centre', 'icon': Icons.storefront},
  ];

  // ===========================================================================
  // --- INTERACTIVE METHODS ---
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    // THE FIX: Check if a category was passed from the previous screen.
    // If yes, clear the default 'Museums' and use the user's actual selection!
    if (widget.filterCategoryId != null && widget.filterCategoryId!.isNotEmpty) {
      _selectedVibes.clear();
      _selectedVibes.add(widget.filterCategoryId!);
    }
  }

  /// Opens the native time picker. Parses the string state into integers,
  /// and updates the UI only if the user confirms a valid time.
  Future<void> _selectStartTime() async {
    int initialHour = int.tryParse(_startTime.split(":")[0]) ?? 18;
    int initialMinute = int.tryParse(_startTime.split(":")[1]) ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      // Injects the app's primary theme into the native picker for UI consistency.
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

  /// Displays a customized bottom sheet to select tour duration (1 to 8 hours).
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.loc.selectTourDuration,
                  style: const TextStyle(
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
                        "$hours ${context.loc.hours}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        setState(() {
                          _availableHours = hours.toDouble();
                        });
                        Navigator.pop(context); // Dismiss sheet safely
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

  /// Adds or removes a category constraint. Keeps the UI state in sync
  /// with the internal list payload.
  void _toggleCategory(String category) {
    setState(() {
      if (_selectedVibes.contains(category)) {
        // Prevent deselecting the last category to ensure the AI always has a prompt
        if (_selectedVibes.length > 1) {
          _selectedVibes.remove(category);
        }
      } else {
        _selectedVibes.add(category);
      }
    });
  }

  String _categoryLabel(AppLocalizations loc, String value) {
    switch (value) {
      case 'Museums':
        return loc.museumsFull;
      case 'Heritage and Tradition':
        return loc.heritageAndTradition;
      case 'Libraries':
        return loc.librariesFull;
      case 'Conferences and Forums':
        return loc.conferencesAndForums;
      case 'Cultural Institutions':
        return loc.culturalInstitutionsFull;
      case 'Exhibition and Convention Centre':
        return loc.exhibitionAndConvention;
      default:
        return value;
    }
  }

  /// The primary orchestration method bridging the UI, Hardware, and AI logic.
  Future<void> _generateAiTour() async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final localizations = AppLocalizations(languageProvider.currentLocale);

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear stale errors on retry
    });

    try {
      // 1. Fetch Location natively via our dedicated Service class
      Position? pos = await LocationService.getCurrentLocation();

      // 2. Trigger the AI Backend, falling back to Riyadh coordinates if GPS is denied
      final tourData = await AiRemoteSource().generateSmartTour(
        lat: pos?.latitude ?? 24.7136,
        lng: pos?.longitude ?? 46.6753,
        availableHours: _availableHours,
        preferences: _selectedVibes.join(", "),
        localizedPreferences: _selectedVibes
            .map((value) => _categoryLabel(localizations, value))
            .join(", "),
        languageCode: languageProvider.currentLanguage,
        startTime: _startTime,
      );

      setState(() {
        _isLoading = false;
      });

      // 3. Delegation: Push to the next screen and hand off the successful JSON payload.
      // We check if (mounted) to prevent memory leaks if the user navigated away during the API call.
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SmartTourScreen(tourData: tourData),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = localizations.couldNotGenerateTour;
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // --- UI COMPONENTS ---
  // ===========================================================================

  /// Builds a dynamic, tappable filter pill for categories.
  Widget _buildCategoryChip(String value, String label, IconData icon) {
    bool isSelected = _selectedVibes.contains(value);
    return GestureDetector(
      onTap: () => _toggleCategory(value),
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

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
        title: Text(
          loc.aiRouteGenerator,
          style: const TextStyle(
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
              // Conditional rendering based on the async state machine (_isLoading).
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            loc.waselAICalculatingTour,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Text(
                          loc.designYourPerfectEvening,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          loc.whatAreYouInTheMoodFor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Wrap allows the chips to natively overflow to the next line
                        // making it highly responsive across different screen widths.
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _categories
                              .map(
                                (cat) => _buildCategoryChip(
                                  cat['value'],
                                  _categoryLabel(loc, cat['value']),
                                  cat['icon'],
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.startTime,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                        border: Border.all(
                                          color: AppColors.primary,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _startTime,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.duration,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                        border: Border.all(
                                          color: AppColors.primary,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${_availableHours.toInt()} ${loc.hours}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
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
                    ),
            ),
          ),

          // Action button fixed to the bottom of the screen.
          if (!_isLoading)
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
                  child: Text(
                    loc.generateSmartRoute,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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