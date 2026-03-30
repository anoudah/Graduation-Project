import 'package:flutter/material.dart';
// Alanoud added: Import the AI source to talk to Python
import '../../data/datasources/ai_remote_source.dart'; 

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;

  const CategoryScreen({
    Key? key,
    required this.categoryName,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Alanoud added: Initialize AI Source and Future to hold the live data
  final AiRemoteSource _aiSource = AiRemoteSource();
  late Future<List<dynamic>> _categoryEventsFuture;

  @override
  void initState() {
    super.initState();
    // Alanoud added: Fetch dynamic data from Python based on the tapped category!
    _categoryEventsFuture = _aiSource.fetchEventsByCategory(widget.categoryName);
  }

  // Alanoud removed: The hardcoded _getCategoryItems map is gone!

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopBar(context),

            // FutureBuilder replaces the static header and list
            FutureBuilder<List<dynamic>>(
              future: _categoryEventsFuture,
              builder: (context, snapshot) {
                // State 1: Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFF6B4B8A)),
                          SizedBox(height: 16),
                          Text("Wasel AI is calculating live crowds..."),
                        ],
                      ),
                    ),
                  );
                }

                // State 2: Error
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                }

                // State 3: Success!
                final liveItems = snapshot.data ?? [];

                return Column(
                  children: [
                    // Pass the real count to the header
                    _buildCategoryHeader(context, isMobile, liveItems.length),
                    // Pass the real data to the list
                    _buildCategoryItemsList(context, isMobile, liveItems),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333), size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.categoryName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF333333), size: 24), onPressed: () {}),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.filter_list, color: Color(0xFF333333), size: 24), onPressed: () {}),
        ],
      ),
    );
  }

  // Alanoud added: Pass the totalItemCount so the header updates dynamically
  Widget _buildCategoryHeader(BuildContext context, bool isMobile, int totalItemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8DDF5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(widget.categoryIcon, color: const Color(0xFF6B4B8A), size: 40),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoryName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalItemCount places available', // Dynamic count!
                      style: const TextStyle(fontSize: 14, color: Color(0xFF999999), fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Alanoud added: Pass the dynamic AI list into the builder
  Widget _buildCategoryItemsList(BuildContext context, bool isMobile, List<dynamic> categoryItems) {
    if (categoryItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text("No events found for this category.", style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: categoryItems.map((item) {
          
          // Alanoud added: AI Crowd Color Logic
          String crowdStatus = item['Live_Crowd_Status'] ?? "LOW";
          Color crowdColor = Colors.green;
          if (crowdStatus == "MEDIUM") crowdColor = Colors.orange;
          if (crowdStatus == "HIGH") crowdColor = Colors.red;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                // Image
                Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200], // Fallback background
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      // Map to Python Image_Url
                      item['Image_Url'] ?? 'https://via.placeholder.com/120x120?text=No+Image',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['Title'] ?? 'Unknown Event', // Map to Python Title
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['About'] ?? item['Category'] ?? '', // Map to Python About/Category
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999), fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        
                        // Distance and AI Crowd Badge
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B4B8A)),
                            const SizedBox(width: 4),
                            
                            // Alanoud added: Placeholder for distance calculation
                            const Text(
                              '-- km', // TODO: Replace with real GPS distance math later
                              style: TextStyle(
                                fontSize: 12, 
                                color: Color(0xFF6B4B8A), 
                                fontWeight: FontWeight.w500, 
                                fontFamily: 'Poppins'
                              ),
                            ),
                            
                            const Spacer(), // Pushes the AI badge to the far right
                            
                            // Alanoud added: Dynamic AI Crowd Badge!
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: crowdColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                crowdStatus,
                                style: TextStyle(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold, 
                                  color: crowdColor, 
                                  fontFamily: 'Poppins'
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrow Icon
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B4B8A)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}