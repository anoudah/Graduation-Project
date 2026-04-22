import '../models/event.dart';
import '../repositories/i_event_repository.dart';

class GetAllEventsUseCase {
  final IEventRepository repository;

  GetAllEventsUseCase(this.repository);

  // هذه الدالة هي اللي بتناديها الشاشة عشان تجيب الفعاليات
  Future<List<EventModel>> execute() async {
    return await repository.getAllEvents();
  }
}
