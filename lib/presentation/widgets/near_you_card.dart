import 'package:flutter/material.dart';

class NearYouCard extends StatelessWidget {
  // Receives the location details (name, distance)
  final Map<String, String> locationData;

  const NearYouCard({Key? key, required this.locationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main container for the wide card
    return Container(
      width: 280, // Wider fixed width for the horizontal layout
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      // Row is used here instead of Column because the image is on the left, text on the right
      child: Row(
        children: [
          // The image container
          Container(
            width: 100,
            margin: const EdgeInsets.all(12), // Adds space around the image inside the card
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // We use DecorationImage here so we can easily apply border radius to it
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/100x100?text=Location'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Expanded is critical here! It prevents the text from overflowing past the right edge
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              // Column stacks the location name above the distance text
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
                mainAxisAlignment: MainAxisAlignment.center, // Centers the text vertically
                children: [
                  Text(
                    locationData['name']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6), // Small gap between name and distance
                  Text(
                    locationData['distance']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}