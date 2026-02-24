import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: const Color(0xFF6B4B8A),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            title: Text('What does this app do?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'It helps users discover cultural events happening in Riyadh in one place with clear details and AI-based recommendations.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I create an account?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Click Sign Up on the home page and enter your details.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How can I find events?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Browse from the home screen or use the search feature.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How can I save events I\'m interested in?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Click the heart icon to add events to favorites.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How can I give feedback after attending an event?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Go to your saved events and leave a review or rating.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Does the app work outside Riyadh?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Currently, the app focuses only on Riyadh events.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
