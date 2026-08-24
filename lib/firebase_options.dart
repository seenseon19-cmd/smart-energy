/// إعدادات Firebase — يتم توليدها تلقائياً بواسطة FlutterFire CLI
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.windows: return windows;
      default:
        throw UnsupportedError('DefaultFirebaseOptions not configured for ${defaultTargetPlatform.name}');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9JsjodY8hKdKz2lAIm4q9FGkFfZl3Ca8',
    appId: '1:773015043463:android:f3a7b2701cb74fbacaa722',
    messagingSenderId: '773015043463',
    projectId: 'smartenergy-781b9',
    storageBucket: 'smartenergy-781b9.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDsWTJ1tK5-Tqk5V6GunQG4tl6WlRXNiyA',
    appId: '1:773015043463:web:860c5b1a0fccde8fcaa722',
    messagingSenderId: '773015043463',
    projectId: 'smartenergy-781b9',
    authDomain: 'smartenergy-781b9.firebaseapp.com',
    storageBucket: 'smartenergy-781b9.firebasestorage.app',
    measurementId: 'G-8JVQB1LVS9',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGw3QVxPzRm-y4AkOGdL8R9R_2dFO_jQo',
    appId: '1:653501673398:web:825a4c4937174545841b17',
    messagingSenderId: '653501673398',
    projectId: 'smartenergylibya',
    authDomain: 'smartenergylibya.firebaseapp.com',
    databaseURL: 'https://smartenergylibya-default-rtdb.firebaseio.com',
    storageBucket: 'smartenergylibya.firebasestorage.app',
  );
}