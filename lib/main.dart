import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// 1.   استيرادات طبقة البيانات (Data Layer)
import 'data/datasources/firebase_remote_source.dart';
import 'data/repositories/event_repository_impl.dart';

// 2. استيرادات طبقة الدومين (Domain Layer)
import 'domain/usecases/get_all_events_usecase.dart';

// 3. استيرادات طبقة التطبيق (Application Layer)
import 'application/providers/event_provider.dart';

void main() async {
  // السطرين القادمة هي "صمام الأمان" لضمان اتصال الفايربيس قبل تشغيل الشاشات
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    /* استخدام MultiProvider هنا هو "الاحترافية" بعينها؛ 
       لأنه يسمح لكِ بإضافة Providers أخرى مستقبلاً (مثل AuthProvider) 
       دون الحاجة لتغيير هيكلة التطبيق.
    */
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
      debugShowCheckedModeBanner: false, // لإزالة شريط الـ Debug المزعج
      title: 'Wasel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Tajawal', // إذا كنتِ تستخدمين خطاً عربياً، هذا مكانه
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            "Wasel System is Ready!\nData Connection: OK",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
