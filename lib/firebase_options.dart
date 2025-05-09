// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAz9ovQOJ2QlaL0V7k0iv-IBF5PNtg5imI',
    appId: '1:43042287657:web:4508ad630324075a562c38',
    messagingSenderId: '43042287657',
    projectId: 'emoji-2fd13',
    authDomain: 'emoji-2fd13.firebaseapp.com',
    storageBucket: 'emoji-2fd13.firebasestorage.app',
    measurementId: 'G-LY6NR44C2Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZAPRL1c6lXIDKfIbPFmtpT5-E3MBFetM',
    appId: '1:43042287657:android:e6efaf4074404a7a562c38',
    messagingSenderId: '43042287657',
    projectId: 'emoji-2fd13',
    storageBucket: 'emoji-2fd13.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdEM5Bf39WgTtOgDRH9JslK03DTBf6fbY',
    appId: '1:43042287657:ios:ba546c978c12e506562c38',
    messagingSenderId: '43042287657',
    projectId: 'emoji-2fd13',
    storageBucket: 'emoji-2fd13.firebasestorage.app',
    iosBundleId: 'com.example.emoji',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBdEM5Bf39WgTtOgDRH9JslK03DTBf6fbY',
    appId: '1:43042287657:ios:ba546c978c12e506562c38',
    messagingSenderId: '43042287657',
    projectId: 'emoji-2fd13',
    storageBucket: 'emoji-2fd13.firebasestorage.app',
    iosBundleId: 'com.example.emoji',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAz9ovQOJ2QlaL0V7k0iv-IBF5PNtg5imI',
    appId: '1:43042287657:web:7a53ee5c7a5b7042562c38',
    messagingSenderId: '43042287657',
    projectId: 'emoji-2fd13',
    authDomain: 'emoji-2fd13.firebaseapp.com',
    storageBucket: 'emoji-2fd13.firebasestorage.app',
    measurementId: 'G-31GGHTS3NG',
  );

}