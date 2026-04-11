import 'package:flutter/material.dart';
import '../screens/library_details_screen.dart';

class CompactEventCard extends StatelessWidget {
  // We pass the event data map into the widget through the constructor
  final Map<String, String> eventData;

  const CompactEventCard({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GestureDetector allows the entire card to be tappable
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          // Passes the specific event data to the details screen when tapped
          builder: (context) => LibraryDetailsScreen(eventData: eventData),
        ),
      ),
      // The main container for the card
      child: Container(
        width: 220, // Fixed width so it looks good in a horizontal list
        margin: const EdgeInsets.only(right: 16, bottom: 8), // Bottom margin leaves room for the shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Rounds all 4 corners of the white card
          // Adds the subtle drop shadow beneath the card
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
          ],
        ),
        // Column stacks the image on top and the text on the bottom
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Forces children to fill the width
          children: [
            // Expanded allows the image to take up all remaining vertical space
            Expanded(
              // ClipRRect is crucial here: it clips the square image so it matches
              // the rounded top corners of the parent Container
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  eventData['Image_Url']!,
                  fit: BoxFit.cover, // Ensures the image fills the space without stretching
                ),
              ),
            ),
            // Padding around the text at the bottom of the card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                eventData['Title']!,
                maxLines: 2, // Restricts title to 2 lines
                overflow: TextOverflow.ellipsis, // Adds "..." if the title is too long
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}