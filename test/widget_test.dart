import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasel/application/providers/event_provider.dart';
import 'package:wasel/application/providers/language_provider.dart';
import 'package:wasel/core/utils/geo_utils.dart';
import 'package:wasel/domain/models/event.dart';
import 'package:wasel/domain/repositories/i_event_repository.dart';
import 'package:wasel/domain/usecases/get_all_events_usecase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('defaults to English when no saved language exists', () async {
      final provider = LanguageProvider();

      // Allow the asynchronous SharedPreferences load to finish.
      await _flushAsyncWork();

      expect(provider.currentLocale, const Locale('en'));
      expect(provider.currentLanguage, 'en');
      expect(provider.isEnglish, isTrue);
      expect(provider.isArabic, isFalse);
    });

    test('setLanguage stores Arabic preference and notifies listeners', () async {
      final provider = LanguageProvider();
      await _flushAsyncWork();

      var notificationCount = 0;
      provider.addListener(() => notificationCount++);

      await provider.setLanguage('ar');
      final prefs = await SharedPreferences.getInstance();

      expect(provider.currentLocale, const Locale('ar'));
      expect(provider.isArabic, isTrue);
      expect(prefs.getString('language_code'), 'ar');
      expect(notificationCount, greaterThanOrEqualTo(1));
    });
  });

  group('AppUtils distance formatting', () {
    testWidgets('formats short distances in meters for English UI', (
      tester,
    ) async {
      late String formattedDistance;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                formattedDistance = AppUtils.formatDistance(850, context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(formattedDistance, '850 m');
    });

    testWidgets('formats long distances in kilometers for English UI', (
      tester,
    ) async {
      late String formattedDistance;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                formattedDistance = AppUtils.formatDistance(4200, context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(formattedDistance, '4.2 km');
    });

    testWidgets('calculates a minimum one-minute drive time', (tester) async {
      late String driveTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                driveTime = AppUtils.calculateDriveTime(10, context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(driveTime, '~1 min drive');
    });
  });

  group('EventProvider', () {
    test('fetchEvents loads events and clears loading state', () async {
      final repository = _FakeEventRepository(events: <EventModel>[
        _event(id: 'event-1', title: 'Riyadh Art Night'),
        _event(id: 'event-2', title: 'Museum Tour'),
      ]);
      final provider = EventProvider(
        getAllEventsUseCase: GetAllEventsUseCase(repository),
      );

      await provider.fetchEvents();

      expect(provider.events, hasLength(2));
      expect(provider.events.first.title, 'Riyadh Art Night');
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchEvents exposes loading state while repository is pending', () async {
      final completer = Completer<List<EventModel>>();
      final repository = _FakeEventRepository(completer: completer);
      final provider = EventProvider(
        getAllEventsUseCase: GetAllEventsUseCase(repository),
      );

      final fetchFuture = provider.fetchEvents();
      await Future<void>.delayed(Duration.zero);

      expect(provider.isLoading, isTrue);
      expect(provider.errorMessage, isNull);

      completer.complete(<EventModel>[_event(id: 'event-1')]);
      await fetchFuture;

      expect(provider.isLoading, isFalse);
      expect(provider.events, hasLength(1));
    });

    test('fetchEvents records an error when repository fails', () async {
      final repository = _FakeEventRepository(
        error: Exception('Firebase unavailable'),
      );
      final provider = EventProvider(
        getAllEventsUseCase: GetAllEventsUseCase(repository),
      );

      await provider.fetchEvents();

      expect(provider.events, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Firebase unavailable'));
    });
  });
}

Future<void> _flushAsyncWork() async {
  // SharedPreferences is loaded asynchronously by LanguageProvider's constructor.
  // Flushing the microtask queue keeps these tests deterministic without
  // changing production code.
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

EventModel _event({
  required String id,
  String title = 'Cultural Event',
}) {
  final now = DateTime(2026, 5, 3, 10);

  return EventModel(
    id: id,
    title: title,
    about: 'A test cultural event used by the unit test suite.',
    category: 'Culture',
    categoryId: 'culture',
    bookingUrl: 'https://example.com/book',
    imageUrl: 'https://example.com/event.jpg',
    locationAddress: 'Riyadh',
    phone: '+966500000000',
    price: 'Free',
    rating: 4.5,
    schedule: 'Daily',
    tags: const <String>['culture', 'art'],
    startTime: now,
    endTime: now.add(const Duration(hours: 2)),
    venueCapacity: 100,
  );
}

class _FakeEventRepository implements IEventRepository {
  _FakeEventRepository({
    this.events = const <EventModel>[],
    this.completer,
    this.error,
  });

  final List<EventModel> events;
  final Completer<List<EventModel>>? completer;
  final Object? error;

  @override
  Future<List<EventModel>> getAllEvents() {
    if (error != null) {
      return Future<List<EventModel>>.error(error!);
    }

    return completer?.future ?? Future<List<EventModel>>.value(events);
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    for (final event in events) {
      if (event.id == id) {
        return event;
      }
    }

    return null;
  }

  @override
  Future<List<EventModel>> getEventsByCategory(String categoryId) async {
    return events.where((event) => event.categoryId == categoryId).toList();
  }
}
