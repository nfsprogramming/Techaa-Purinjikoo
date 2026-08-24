import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmf-jSMoe8Bhotn1ih8WBy3Y-3MNqNamc',
    appId: '1:414743824161:android:51e60506fe84d4d3ec2060',
    messagingSenderId: '414743824161',
    projectId: 'techaa-purinjikoo',
    storageBucket: 'techaa-purinjikoo.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmf-jSMoe8Bhotn1ih8WBy3Y-3MNqNamc',
    appId: '1:414743824161:web:51e60506fe84d4d3ec2060',
    messagingSenderId: '414743824161',
    projectId: 'techaa-purinjikoo',
    storageBucket: 'techaa-purinjikoo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmf-jSMoe8Bhotn1ih8WBy3Y-3MNqNamc',
    appId: '1:414743824161:ios:51e60506fe84d4d3ec2060',
    messagingSenderId: '414743824161',
    projectId: 'techaa-purinjikoo',
    storageBucket: 'techaa-purinjikoo.firebasestorage.app',
    iosBundleId: 'com.nfsprogramming.techaapurinjikoo',
  );
}
