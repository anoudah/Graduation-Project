//The concrete implementation that fetches data from Firebase and maps it to Domain Event objects.
import '../../domain/repositories/i_event_repository.dart';
import '../../domain/models/event.dart';
import '../datasources/firebase_remote_source.dart';

// 1. هنا نقول أن هذا الكلاس "يُنفذ" الوعود الموجودة في الـ Interface
class EventRepositoryImpl implements IEventRepository {
  // 2. نحتاج الـ DataSource لجلب البيانات الخام
  final EventsFirestoreDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventModel>> getAllEvents() async {
    // 3. استدعاء الدالة التي كتبناها في الـ DataSource لجلب كل الفعاليات
    return await remoteDataSource.getEvents();
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    // 4. جلب فعالية واحدة (مثلاً عند الضغط على كرت "المتحف الوطني")
    return await remoteDataSource.getEventById(id);
  }

  @override
  Future<List<EventModel>> getEventsByCategory(String categoryId) async {
    //   5. منطق إضافي: نجلب الكل ثم نصفي (Filter) حسب النوع
    final allEvents = await remoteDataSource.getEvents();
    return allEvents.where((event) => event.categoryId == categoryId).toList();
  }
}
