import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('This platform is not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTaCKO5EKvogHzz4she8SMmmjWPG1A70Q',
    appId: '1:569239102195:web:0d2f70c3bafc47a6774d86',
    messagingSenderId: '569239102195',
    projectId: 'onlineshop-d6001',
    authDomain: 'onlineshop-d6001.firebaseapp.com',
    storageBucket: 'onlineshop-d6001.firebasestorage.app', // ✅ Исправлено
    measurementId: 'G-MCC5PDY5GJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCHgG97tiQ5SNXfFTIncD8ZORbfM_oLYn4',
    appId: '1:569239102195:android:be98f9f4ef6baaee774d86',
    messagingSenderId: '569239102195',
    projectId: 'onlineshop-d6001',
    storageBucket: 'onlineshop-d6001.firebasestorage.app', // ✅ Исправлено
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAet_eIN9n_Vo-OG4qCE31xjAdWslnjR18',
    appId: '1:569239102195:ios:2c181959491686e8774d86',
    messagingSenderId: '569239102195',
    projectId: 'onlineshop-d6001',
    storageBucket: 'onlineshop-d6001.firebasestorage.app', // ✅ Исправлено
    iosBundleId: 'com.example.onlineShop', // ✅ Проверь
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAet_eIN9n_Vo-OG4qCE31xjAdWslnjR18',
    appId: '1:569239102195:ios:2c181959491686e8774d86',
    messagingSenderId: '569239102195',
    projectId: 'onlineshop-d6001',
    storageBucket: 'onlineshop-d6001.firebasestorage.appm', // ✅ Исправлено
    iosBundleId: 'com.example.onlineShop', // ✅ Проверь
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCTaCKO5EKvogHzz4she8SMmmjWPG1A70Q',
    appId: '1:569239102195:web:b6387ea18f034438774d86',
    messagingSenderId: '569239102195',
    projectId: 'onlineshop-d6001',
    authDomain: 'onlineshop-d6001.firebaseapp.com',
    storageBucket: 'onlineshop-d6001.firebasestorage.app', // ✅ Исправлено
    measurementId: 'G-CD4ED4CNZX',
  );
}
