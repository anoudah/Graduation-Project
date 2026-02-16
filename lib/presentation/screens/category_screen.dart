import 'package:flutter/material.dart';

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
  late List<Map<String, String>> categoryItems;

  @override
  void initState() {
    super.initState();
    categoryItems = _getCategoryItems(widget.categoryName);
  }

  List<Map<String, String>> _getCategoryItems(String category) {
    final itemsMap = {
      'Libraries': [
        {'name': 'King Fahad National Library', 'distance': '2.3 km', 'description': 'Saudi Arabia\'s largest library'},
        {'name': 'Riyadh Central Library', 'distance': '3.1 km', 'description': 'Modern public library'},
        {'name': 'Al Riyadh Library', 'distance': '4.5 km', 'description': 'Heritage and modern collections'},
        {'name': 'Prince Sultan Library', 'distance': '5.2 km', 'description': 'Educational library'},
      ],
      'Heritage and Tradition': [
        {'name': 'Diriyah', 'distance': '1.8 km', 'description': 'Historic site of Saudi Arabia'},
        {'name': 'Al Masmak Palace', 'distance': '2.1 km', 'description': 'Historic fortress'},
        {'name': 'Wadi Hanifah', 'distance': '3.7 km', 'description': 'Natural heritage site'},
        {'name': 'Al Ula Heritage Site', 'distance': '8.5 km', 'description': 'Ancient desert heritage'},
      ],
      'Museums': [
        {'name': 'Saudi National Museum', 'distance': '2.5 km', 'description': 'Comprehensive history museum'},
        {'name': 'Riyadh Museum of Contemporary Art', 'distance': '3.2 km', 'description': 'Modern art exhibitions'},
        {'name': 'Al Masmak Museum', 'distance': '2.0 km', 'description': 'Military history museum'},
        {'name': 'Photography Museum', 'distance': '4.1 km', 'description': 'Photography exhibitions'},
      ],
      'Conferences and Forums': [
        {'name': 'Riyadh International Convention Center', 'distance': '2.8 km', 'description': 'Major conference venue'},
        {'name': 'King Fahad Conference Hall', 'distance': '3.5 km', 'description': 'Government conference space'},
        {'name': 'Business Forum Center', 'distance': '4.2 km', 'description': 'Corporate events venue'},
        {'name': 'Tech Summit Hall', 'distance': '5.0 km', 'description': 'Technology conferences'},
      ],
      'Cultural Institutions': [
        {'name': 'King Fahad Cultural Center', 'distance': '2.4 km', 'description': 'Major cultural hub'},
        {'name': 'Arts and Culture Institute', 'distance': '3.8 km', 'description': 'Arts education center'},
        {'name': 'Heritage Society', 'distance': '4.3 km', 'description': 'Cultural preservation organization'},
        {'name': 'National Center for Arts', 'distance': '5.1 km', 'description': 'Performing arts center'},
      ],
      'Exhibition and Convention Centre': [
        {'name': 'Riyadh Expo Center', 'distance': '3.0 km', 'description': 'Major exhibition venue'},
        {'name': 'International Convention Center', 'distance': '3.6 km', 'description': 'Trade shows and exhibitions'},
        {'name': 'Art Exhibition Hall', 'distance': '2.9 km', 'description': 'Contemporary art shows'},
        {'name': 'Regional Exhibition Space', 'distance': '4.7 km', 'description': 'Regional exhibitions'},
      ],
    };

    return itemsMap[category] ?? [];
  }

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

            // Category Header
            _buildCategoryHeader(context, isMobile),

            // Category Items List
            _buildCategoryItemsList(context, isMobile),

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
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF333333), size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 16),

          // Title
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

          // Search Icon
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF333333), size: 24),
            onPressed: () {},
          ),

          const SizedBox(width: 8),

          // Filter Icon
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF333333), size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8DDF5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.categoryIcon,
                  color: const Color(0xFF6B4B8A),
                  size: 40,
                ),
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
                      '${categoryItems.length} places available',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                        fontFamily: 'Poppins',
                      ),
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

  Widget _buildCategoryItemsList(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: categoryItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
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
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/120x120?text=Place',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['description'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF6B4B8A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['distance'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B4B8A),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrow Icon
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: const Color(0xFF6B4B8A),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
