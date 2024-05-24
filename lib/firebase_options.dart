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
    apiKey: 'AIzaSyBbCXGfRHiDcukktxgvyapZXQMP9FNd3J4',
    appId: '1:355394210028:web:43f1102cc94a85ecf3fdc9',
    messagingSenderId: '355394210028',
    projectId: 'fstore-73acb',
    authDomain: 'fstore-73acb.firebaseapp.com',
    storageBucket: 'fstore-73acb.appspot.com',
    measurementId: 'G-HGBYYNE2LB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAJNvek_2-mRzH6lmORn958K1RESnT5uY',
    appId: '1:355394210028:android:a951402db3619523f3fdc9',
    messagingSenderId: '355394210028',
    projectId: 'fstore-73acb',
    storageBucket: 'fstore-73acb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTA0A9Zqoolm8awToOjoF3_rgdwGJy-1U',
    appId: '1:355394210028:ios:c00c3f89a31f36f2f3fdc9',
    messagingSenderId: '355394210028',
    projectId: 'fstore-73acb',
    storageBucket: 'fstore-73acb.appspot.com',
    iosBundleId: 'com.example.newcap',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBTA0A9Zqoolm8awToOjoF3_rgdwGJy-1U',
    appId: '1:355394210028:ios:c00c3f89a31f36f2f3fdc9',
    messagingSenderId: '355394210028',
    projectId: 'fstore-73acb',
    storageBucket: 'fstore-73acb.appspot.com',
    iosBundleId: 'com.example.newcap',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBbCXGfRHiDcukktxgvyapZXQMP9FNd3J4',
    appId: '1:355394210028:web:f1914385ecc784f4f3fdc9',
    messagingSenderId: '355394210028',
    projectId: 'fstore-73acb',
    authDomain: 'fstore-73acb.firebaseapp.com',
    storageBucket: 'fstore-73acb.appspot.com',
    measurementId: 'G-X4L0PXYYZY',
  );
}