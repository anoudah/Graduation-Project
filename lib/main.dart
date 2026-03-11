import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// 1. استيرادات طبقة البيانات
import 'data/datasources/firebase_remote_source.dart';
import 'data/repositories/event_repository_impl.dart';

// 2. استيرادات طبقة الدومين
import 'domain/usecases/get_all_events_usecase.dart';

// 3. استيرادات طبقة التطبيق
import 'application/providers/event_provider.dart';

// نورة: أضفنا استيراد الشاشة لكي نتمكن من عرضها عند تشغيل التطبيق
import 'presentation/screens/museums_screen.dart';

void main() async {
  // صمام الأمان لضمان تهيئة إضافات فلاتر والفايربيس
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventProvider(
            getAllEventsUseCase: GetAllEventsUseCase(
              EventRepositoryImpl(
                EventsFirestoreDataSource(FirebaseFirestore.instance),
              ),
            ),
          ),
        ),
      ],
      child: const WaselApp(),
    ),
  );
}

class WaselApp extends StatelessWidget {
  const WaselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wasel',
      theme: ThemeData(
        // تم تغيير اللون ليناسب هوية التطبيق الكحلية (اختياري)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Tajawal',
      ),
      // نورة: هنا قمنا بتغيير الشاشة الرئيسية لتفتح على قائمة المتاحف فوراً
      home: const MuseumsScreen(),
    );
  }
}
