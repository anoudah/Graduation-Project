import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // If you try to run this on an Android/iOS emulator later without adding their specific keys, it will safely tell you.
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform yet.',
    );
  }

  // Here are your exact Wasel keys translated into Dart!
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNyWguyHXR-fomByifyb9XXk46IB19EdI',
    appId: '1:417277582360:web:6991a6252a89589b01776d',
    messagingSenderId: '417277582360',
    projectId: 'wsal-2b30a',
    authDomain: 'wsal-2b30a.firebaseapp.com',
    databaseURL: 'https://wsal-2b30a-default-rtdb.firebaseio.com',
    storageBucket: 'wsal-2b30a.firebasestorage.app',
    measurementId: 'G-NNCFS3756T',
  );
}