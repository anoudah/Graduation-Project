import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme.dart';
import '../screens/library_details_screen.dart'; // Required for clicking the slider

class HeroSlider extends StatefulWidget {
  final bool isMobile;
  final Future<List<dynamic>> trendingFuture; 

  const HeroSlider({required this.isMobile, required this.trendingFuture, Key? key}) : super(key: key);

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  int _currentSlideIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentSlideIndex + 1;
        if (nextPage >= 3) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage, 
          duration: const Duration(milliseconds: 500), 
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 30, vertical: 30),
      child: FutureBuilder<List<dynamic>>(
        future: widget.trendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: widget.isMobile ? 250 : 350, 
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary))
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink(); // Hide slider if no data
          }

          final trendingEvents = snapshot.data!;
          
          return widget.isMobile 
              ? _buildMobile(trendingEvents) 
              : _buildDesktop(trendingEvents);
        }
      ),
    );
  }

  Widget _buildSlider(double height, List<dynamic> events) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView.builder( 
          controller: _pageController,
          itemCount: events.length,
          onPageChanged: (index) {
            setState(() => _currentSlideIndex = index);
          },
          itemBuilder: (context, index) {
            final event = Map<String, dynamic>.from(events[index]);
            
            String imageUrl = event['Image_Url'] ?? '';
            if (imageUrl.isEmpty || imageUrl.contains('via.placeholder.com')) {
              imageUrl = 'https://placehold.co/800x400/png?text=Trending+Event';
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LibraryDetailsScreen(eventData: event),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.4, 1.0], 
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text("🔥 TRENDING", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event['Title'] ?? 'Unknown Event',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['Category'] ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentSlideIndex ? AppColors.primary : AppColors.divider, 
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(List<dynamic> events) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Column(children: [_buildSlider(350, events), const SizedBox(height: 16), _buildDots(events.length)])),
        const SizedBox(width: 60),
        const Expanded(
          child: Text('SEE WHAT\nIS HAPPENING\nHERE', style: AppTextStyles.heroDesktop), 
        ),
      ],
    );
  }

  Widget _buildMobile(List<dynamic> events) {
    return Column(
      children: [
        _buildSlider(250, events),
        const SizedBox(height: 16),
        _buildDots(events.length),
        const SizedBox(height: 30),
        const Text('SEE WHAT IS HAPPENING HERE', textAlign: TextAlign.center, style: AppTextStyles.heroMobile),
      ],
    );
  }
}