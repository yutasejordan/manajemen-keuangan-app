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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDsFw5IoL5WY48NWR4pTKGi0BHczWMpmOY',
    appId: '1:1030758202635:web:a29ac59f7d58363787360e',
    messagingSenderId: '1030758202635',
    projectId: 'manajemen-keuangan-app',
    authDomain: 'manajemen-keuangan-app.firebaseapp.com',
    storageBucket: 'manajemen-keuangan-app.firebasestorage.app',
    measurementId: 'G-RJWNDLSM22',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8KZpMLyGsmJq6DIIZRQkSdNAJ6myCZ3g',
    appId: '1:1030758202635:android:7c110ce41a2b314a87360e',
    messagingSenderId: '1030758202635',
    projectId: 'manajemen-keuangan-app',
    storageBucket: 'manajemen-keuangan-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqxlIgYEs46w7fTin0FC_XqaffcR2FC9A',
    appId: '1:1030758202635:ios:d4979d72144581d687360e',
    messagingSenderId: '1030758202635',
    projectId: 'manajemen-keuangan-app',
    storageBucket: 'manajemen-keuangan-app.firebasestorage.app',
    iosBundleId: 'com.example.manajemenKeuanganApp',
  );
}
