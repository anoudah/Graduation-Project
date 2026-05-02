import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

// 1. Data Layer Imports
import 'data/datasources/firebase_remote_source.dart';
import 'data/repositories/event_repository_impl.dart';

// 2. Domain Layer Imports
import 'domain/usecases/get_all_events_usecase.dart';

// 3. Application Layer Imports
import 'application/providers/event_provider.dart';
import 'application/providers/language_provider.dart';

// UI and Theme Imports
import 'presentation/screens/home_screen.dart';
import 'core/theme.dart'; 

void main() async {
  // Ensure Firebase and Flutter are initialized before the app runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wasel',
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Apply your new global AppTheme here!
          theme: AppTheme.lightTheme, 
          builder: (context, child) {
            return SafeArea(
              // This ensures the notch/status bar never covers your app anywhere
              child: child!, 
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}