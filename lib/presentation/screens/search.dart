import 'package:flutter/material.dart';
import 'dart:async'; // Required for the Timer used in "live search"
import '../../core/theme.dart';
import '../../data/datasources/ai_remote_source.dart';
import '../widgets/compact_event_card.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ==========================================
  // 1. STATE VARIABLES (CONTROLLERS & DATA)
  // ==========================================
  
  // Reads what the user types in the search bar
  final TextEditingController _searchController = TextEditingController();
  
  // Controls the keyboard (allows us to hide it programmatically after searching)
  final FocusNode _searchFocusNode = FocusNode(); 
  
  // The bridge to your Python backend
  final AiRemoteSource _aiSource = AiRemoteSource();
  
  // Holds the actual event data returned from the search
  List<dynamic> _searchResults = [];
  
  // UI State toggles
  bool _isLoading = false;      // Shows the spinning loading circle
  bool _isGridView = false;     // Toggles between Grid (icons) and List views
  String _statusMessage = '';   // Displays errors or "No events found" text
  
  // Timer used for "Debouncing" (Waiting for the user to finish typing before sending the request)
  Timer? _debounce; 

  // Variables for the "Popular Searches" chips
  List<String> _popularSearches = [];
  bool _isLoadingSuggestions = true;

  // ==========================================
  // 2. LIFECYCLE METHODS
  // ==========================================

  @override
  void initState() {
    super.initState();
    // As soon as this screen opens, fetch the categories from the database
    _loadSuggestions();
  }

  // Always clean up controllers and timers when the screen is closed to prevent memory leaks!
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ==========================================
  // 3. CORE LOGIC & API CALLS
  // ==========================================

  /// Fetches unique categories from the Python backend to use as clickable suggestions
  void _loadSuggestions() async {
    final suggestions = await _aiSource.getSearchSuggestions();
    setState(() {
      // If the database returns data, use it. Otherwise, use these hardcoded fallbacks.
      _popularSearches = suggestions.isNotEmpty 
          ? suggestions 
          : ['Museum', 'Library', 'Festival', 'Art'];
      _isLoadingSuggestions = false; // Stop the loading spinner
    });
  }

  /// Triggered every single time the user types or deletes a letter
  void _onSearchChanged(String query) {
    // 1. Cancel the existing timer if the user is still actively typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // 2. If they delete all text, clear the results and show suggestions again
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _statusMessage = '';
      });
      return;
    }

    // 3. Start a new timer. If 500ms passes without them typing, execute the search!
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query, hideKeyboard: false); // Keep keyboard open while typing
    });
  }

  /// Sends the search query to Python and updates the UI with the results
  void _performSearch(String query, {bool hideKeyboard = true}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return; // Prevent empty searches

    // Dismiss the keyboard if the user clicked "Search" or a Suggestion Chip
    if (hideKeyboard) {
      _searchFocusNode.unfocus();
    }

    // Update UI to show the loading spinner
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      // Wait for Python to process the search and return the data
      final results = await _aiSource.searchEvents(cleanQuery);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
        
        // If Python returns an empty list, let the user know
        if (results.isEmpty) {
          _statusMessage = 'No events found for "$cleanQuery".';
        }
      });
    } catch (e) {
      // Handle server crashes or network failures gracefully
      setState(() {
        _isLoading = false;
        _statusMessage = 'Connection error. Make sure your Python server is running!';
      });
    }
  }

  // ==========================================
  // 4. MAIN UI BUILDER
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        
        // --- SEARCH BAR ENCLOSURE ---
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.divider.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode, 
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) => _performSearch(val, hideKeyboard: true),
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search museums, events...',
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
              
              // 1. Decorative icon on the left (Not clickable)
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.iconGrey),
              
              // 2. Action buttons on the right
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Crucial: Keeps the row from taking up the whole bar
                  children: [
                    // The 'Clear' X button
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: AppColors.iconGrey),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _statusMessage = '';
                        });
                      },
                    ),
                    
                    // The highly visible, solid "Search" button
                    GestureDetector(
                      onTap: () => _performSearch(_searchController.text, hideKeyboard: true),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        ),
                        // Using arrow_forward gives it a clear "Go/Submit" feel
                        child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white), 
                      ),
                    ),
                  ],
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        
        // --- VIEW TOGGLE BUTTON (Grid vs List) ---
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.iconGrey,
            ),
            tooltip: 'Toggle View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView; // Flips the boolean true/false
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ==========================================
  // 5. BODY LAYOUT ROUTER
  // ==========================================

  /// Decides exactly what to show on the screen based on the current state
  Widget _buildBody() {
    // 1. Show loading spinner if fetching data
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // 2. Show suggestion chips if the search bar is empty and no results exist
    if (_searchResults.isEmpty && _searchController.text.trim().isEmpty) {
      return _buildSuggestions();
    }

    // 3. Show error or "No events found" text if applicable
    if (_searchResults.isEmpty && _statusMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    // 4. Render the GRID VIEW (Multiple columns, compact cards)
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(24.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260, // Maximum width before wrapping to next row
          mainAxisExtent: 250,     // Locks height to exactly match the CompactEventCard
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final eventData = Map<String, dynamic>.from(_searchResults[index]);
          return CompactEventCard(eventData: eventData, isFullWidth: false);
        },
      );
    }

    // 5. Render the LIST VIEW (Single column, full-width banners)
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // Prevents absurd stretching on Web browsers
        child: ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final eventData = Map<String, dynamic>.from(_searchResults[index]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              // isFullWidth tells the card to render as a horizontal Row instead of a Column
              child: CompactEventCard(eventData: eventData, isFullWidth: true),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 6. SUGGESTIONS WIDGET
  // ==========================================

  /// Builds the "Explore Categories" chips shown before the user starts typing
  Widget _buildSuggestions() {
    if (_isLoadingSuggestions) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),
          // Wrap automatically moves chips to the next line if they run out of horizontal space
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularSearches.map((term) {
              return ActionChip(
                label: Text(term, style: const TextStyle(color: AppColors.textMain)),
                backgroundColor: AppColors.primaryLight.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide.none,
                onPressed: () {
                  // When a chip is tapped, fill the search bar and immediately perform the search
                  _searchController.text = term;
                  _performSearch(term, hideKeyboard: true);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}