//An abstract class specifying required operations (e.g., "get events") without defining the implementation details.
import '../models/event.dart';

abstract class IEventRepository {
  /// جلب جميع الفعاليات من مصدر البيانات
  Future<List<EventModel>> getAllEvents();

  /// جلب فعالية محددة باستخدام المعرف الخاص بها (ID)
  Future<EventModel?> getEventById(String id);

  /// جلب الفعاليات بناءً على التصنيف (مثلاً: Museums)
  Future<List<EventModel>> getEventsByCategory(String categoryId);
}
