import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../../domain/entities/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EventCard(
        event: event,
        onBack: () => Navigator.pop(context),
        onLike: () {},
        onAttendToggle: () {},
        onSuggestRoute: () {},
      ),
    );
  }
}
