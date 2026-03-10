//: Contains the specific implementation for connecting to FirebaseFirestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/event.dart';

class EventsFirestoreDataSource {
  final FirebaseFirestore firestore;

  EventsFirestoreDataSource(this.firestore);

  // جلب كل الفعاليات من مجموعة Events
  Future<List<EventModel>> getEvents() async {
    try {
      final snap = await firestore.collection('Events').get();

      return snap.docs.map((doc) {
        // نمرر البيانات للـ factory اللي عدلناه
        return EventModel.fromFirestore(doc.data());
      }).toList();
    } catch (e) {
      // طباعة الخطأ تساعدك في مرحلة التطوير إذا كانت الـ Rules في فايربيس تمنع الوصول
      print("Error fetching events: $e");
      return [];
    }
  }

  // جلب فعالية واحدة بالـ ID
  Future<EventModel?> getEventById(String id) async {
    try {
      final doc = await firestore.collection('Events').doc(id).get();

      if (!doc.exists || doc.data() == null) return null;

      return EventModel.fromFirestore(doc.data()!);
    } catch (e) {
      print("Error fetching event by ID: $e");
      return null;
    }
  }
}
