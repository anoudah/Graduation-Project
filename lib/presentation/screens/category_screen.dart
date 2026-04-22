import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // norah
import 'library_details_screen.dart'; // norah
// Alanoud added: Import the AI source to talk to Python
import '../../data/datasources/ai_remote_source.dart';
// استدعاء ملف الثيم - تأكدي من صحة المسار في مشروعك
import '../../core/theme.dart'; 

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final IconData categoryIcon;

  const CategoryScreen({
    super.key, 
    required this.categoryName,
    required this.categoryId,
    required this.categoryIcon,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final AiRemoteSource _aiSource = AiRemoteSource();
  late Future<List<dynamic>> _categoryEventsFuture;

@override
  void initState() {
    super.initState();

    // 1. We ONLY ask the Python AI Backend for the data.
    // 2. We use the new ID-based function (e.g., passing "MUS" instead of "Museums").
    _categoryEventsFuture = _aiSource.fetchEventsByCategoryId(widget.categoryId);
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background, // مناداة الثيم
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(context),

            FutureBuilder<List<dynamic>>(
              future: _categoryEventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primary), // مناداة الثيم
                          SizedBox(height: 16),
                          Text("Wasel AI is calculating live crowds..."),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  );
                }

                final liveItems = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildCategoryHeader(context, isMobile, liveItems.length),
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
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textMain, // مناداة الثيم
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.categoryName,
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 20), // مناداة الثيم
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textMain, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.textMain,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    bool isMobile,
    int totalItemCount,
  ) {
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
                  color: AppColors.primaryLight, // مناداة الثيم
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
                  color: AppColors.primary,
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
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalItemCount places available', 
                      style: AppTextStyles.subtitle,
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

  Widget _buildCategoryItemsList(
    BuildContext context,
    bool isMobile,
    List<dynamic> categoryItems,
  ) {
    if (categoryItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text(
          "No events found for this category.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: categoryItems.map((item) {
          String crowdStatus = item['Live_Crowd_Status'] ?? "LOW";
          Color crowdColor = Colors.green;
          if (crowdStatus == "MEDIUM") crowdColor = Colors.orange;
          if (crowdStatus == "HIGH") crowdColor = Colors.red;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LibraryDetailsScreen(
                      eventData: item as Map<String, dynamic>, 
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.avatarBg,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item['Image_Url'] ??
                            'https://via.placeholder.com/120x120?text=No+Image',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              color: AppColors.iconGrey,
                            ),
                      ),
                    ),
                  ),

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
                            item['Title'] ?? 'Unknown Event',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['About'] ?? item['Category'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '-- km',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
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
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}