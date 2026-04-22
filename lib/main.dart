import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 1. Data Layer Imports
import 'data/datasources/firebase_remote_source.dart';
import 'data/repositories/event_repository_impl.dart';

// 2. Domain Layer Imports
import 'domain/usecases/get_all_events_usecase.dart';

// 3. Application Layer Imports
import 'application/providers/event_provider.dart';

// UI Imports
import 'presentation/screens/home_screen.dart';
// import 'presentation/screens/museums_screen.dart';

void main() async {
  // Ensure Firebase and Flutter are initialized before the app runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        // TEAM DECISION: Choose your primary color
        // Purple (Main): const Color(0xFF6B4B8A)
        // Navy (Database): const Color(0xFF1A237E)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4B8A)), 
        
        useMaterial3: true,
        
        // TEAM DECISION: Choose your font
        // 'Poppins' for English, 'Tajawal' for Arabic
        fontFamily: 'Poppins', 
      ),
      // TEAM DECISION: Choose the starting screen
      // HomeScreen() or MuseumsScreen()
      home: const HomeScreen(), 
    );
  }
}