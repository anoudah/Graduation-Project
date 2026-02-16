//: Contains the specific implementation for connecting to FirebaseFirestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/event.dart'; // تأكدي من عدد النقاط

class EventsFirestoreDataSource {
  final FirebaseFirestore firestore;

  EventsFirestoreDataSource(this.firestore);

  // جلب كل الفعاليات من مجموعة Events (بالكبير)
  Future<List<EventModel>> getEvents() async {
    final snap = await firestore.collection('Events').get();

    return snap.docs
        .map(
          (doc) => EventModel.fromFirestore(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  // جلب فعالية واحدة بالـ ID (مثل mus_01)
  Future<EventModel?> getEventById(String id) async {
    final doc = await firestore.collection('Events').doc(id).get();

    if (!doc.exists || doc.data() == null) return null;

    return EventModel.fromFirestore(doc.data() as Map<String, dynamic>);
  }
}
