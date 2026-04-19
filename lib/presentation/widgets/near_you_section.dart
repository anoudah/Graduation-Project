import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../screens/Nearyou.dart';
import 'near_you_card.dart';

class NearYouSection extends StatelessWidget {
  const NearYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA: Static list to represent nearby cultural centers
    final nearByLocations = [
      {'name': 'King Abdul Aziz Historical Center', 'distance': '2.3 km'},
      {'name': 'King Fahad Cultural Center', 'distance': '4.1 km'},
      {'name': 'Saudi National Museum', 'distance': '5.2 km'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: Text('Near you', style: AppTextStyles.sectionTitle)),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearYouScreen())),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('See more'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Horizontal list of specialized NearYouCards
          SizedBox(
            height: 124, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nearByLocations.length,
              itemBuilder: (context, index) {
                return NearYouCard(locationData: nearByLocations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}