import 'package:flutter/material.dart';
import 'event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  final VoidCallback? onBack;
  final VoidCallback? onLike;
  final VoidCallback? onNotify;
  final VoidCallback? onShare;
  final VoidCallback? onAttendToggle;
  final VoidCallback? onSuggestRoute;

  const EventCard({
    super.key,
    required this.event,
    this.onBack,
    this.onLike,
    this.onNotify,
    this.onShare,
    this.onAttendToggle,
    this.onSuggestRoute,
  });

  static const Color _bg = Color(0xFFF7F2F2);
  static const Color _purple = Color(0xFF2E1A73);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                _TopBar(
                  onBack: onBack,
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: Row(
                    children: [
                      // LEFT
                      Expanded(
                        flex: 5,
                        child: _LeftPane(
                          title: event.title,
                          imageUrl: event.imageUrl,
                          isAttending: event.isAttending,
                          commentsCount: event.commentsCount,
                          onLike: onLike,
                          onNotify: onNotify,
                          onShare: onShare,
                          onAttendToggle: onAttendToggle,
                        ),
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Container(width: 1, color: Colors.black12),
                      ),

                      // RIGHT
                      Expanded(
                        flex: 6,
                        child: _RightPane(
                          about: event.about,
                          schedule: event.schedule,
                          price: event.price,
                          crowdPrediction: event.crowdPrediction,
                          phoneNumber: event.phoneNumber,
                          location: event.location,
                          onSuggestRoute: onSuggestRoute,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback? onBack;

  const _TopBar({this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 18,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _TopChip("Libraries"),
              _TopChip("Heritage and Tradition"),
              _TopChip("Museums"),
              _TopChip("Conferences and Forums"),
              _TopChip("Cultural Institutions"),
              _TopChip("Exhibition and Convention center"),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopChip extends StatelessWidget {
  final String text;
  const _TopChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

class _LeftPane extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isAttending;
  final int commentsCount;

  final VoidCallback? onLike;
  final VoidCallback? onNotify;
  final VoidCallback? onShare;
  final VoidCallback? onAttendToggle;

  const _LeftPane({
    required this.title,
    required this.imageUrl,
    required this.isAttending,
    required this.commentsCount,
    this.onLike,
    this.onNotify,
    this.onShare,
    this.onAttendToggle,
  });

  static const Color _purple = Color(0xFF2E1A73);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),

        AspectRatio(
          aspectRatio: 16 / 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isEmpty
                ? Container(
                    color: Colors.black12,
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  )
                : Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            IconButton(
              onPressed: onLike,
              icon: const Icon(Icons.favorite_border),
            ),
            IconButton(
              onPressed: onNotify,
              icon: const Icon(Icons.notifications_none),
            ),
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.ios_share),
            ),
            const Spacer(),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onAttendToggle,
                child: Text(isAttending ? "I'm attending" : "Attend"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Comments: $commentsCount",
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      ],
    );
  }
}

class _RightPane extends StatelessWidget {
  final String about;
  final String schedule;
  final String price;
  final String crowdPrediction;
  final String phoneNumber;
  final String location;

  final VoidCallback? onSuggestRoute;

  const _RightPane({
    required this.about,
    required this.schedule,
    required this.price,
    required this.crowdPrediction,
    required this.phoneNumber,
    required this.location,
    this.onSuggestRoute,
  });

  static const Color _purple = Color(0xFF2E1A73);

  Color _crowdColor(String v) {
    final s = v.toLowerCase().trim();
    if (s.contains('low')) return Colors.green;
    if (s.contains('med')) return Colors.orange;
    if (s.contains('high')) return Colors.red;
    return Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            about,
            style: TextStyle(color: Colors.black.withOpacity(0.75), height: 1.35),
          ),
          const SizedBox(height: 14),

          const Text(
            "Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          _DetailRow(label: "Schedule", value: schedule),
          _DetailRow(label: "Price", value: price),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 120, child: Text("Crowd prediction:", style: TextStyle(fontWeight: FontWeight.w700))),
              Expanded(
                child: Text(
                  crowdPrediction,
                  style: TextStyle(fontWeight: FontWeight.w800, color: _crowdColor(crowdPrediction)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _DetailRow(label: "Phone number", value: phoneNumber),
          _DetailRow(label: "Location", value: location),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onSuggestRoute,
                icon: const Icon(Icons.route),
                label: const Text("Suggest a route"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: TextStyle(color: Colors.black.withOpacity(0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
