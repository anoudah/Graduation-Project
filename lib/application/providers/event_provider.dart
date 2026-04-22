import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import '../../domain/usecases/get_all_events_usecase.dart';

class EventProvider extends ChangeNotifier {
  final GetAllEventsUseCase getAllEventsUseCase;

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters عشان نستخدمهم في الـ UI
  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EventProvider({required this.getAllEventsUseCase});

  // الدالة اللي بتناديها الشاشة أول ما تفتح
  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // هنا نقول للشاشة "طلعي علامة الـ Loading"

    try {
      // نطلب البيانات من الـ Use Case اللي سويتيه
      _events = await getAllEventsUseCase.execute();

      /* ملاحظة لنورة: 
         هنا العنود صديقتك تقدر تضيف كود الـ AI حقها لاحقاً 
         عشان تحسب الـ crowdStatus لكل Event بناءً على الـ venueCapacity 
         اللي أضفتيه أنتِ في الموديل.
      */
    } catch (e) {
      _errorMessage = "حصل خطأ أثناء جلب الفعاليات: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // هنا نقول للشاشة "خلاص وقفي الـ Loading واعرضي البيانات"
    }
  }
}
