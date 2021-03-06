// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAR5UzGjSGDfNC7knxvkWVEB57qudIoXn8',
    appId: '1:659854626505:web:138888d9c0884381d58718',
    messagingSenderId: '659854626505',
    projectId: 'mynote-fluuter-project',
    authDomain: 'mynote-fluuter-project.firebaseapp.com',
    storageBucket: 'mynote-fluuter-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGKmDhgQKEuuWNuf_iUuNSP8oGFXUDU0M',
    appId: '1:659854626505:android:1c76cbae42e83002d58718',
    messagingSenderId: '659854626505',
    projectId: 'mynote-fluuter-project',
    storageBucket: 'mynote-fluuter-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSYN-XaCw8rLCxp8FsmJ7XLqBXVx5rjRM',
    appId: '1:659854626505:ios:75fdc5ea8dc7fa87d58718',
    messagingSenderId: '659854626505',
    projectId: 'mynote-fluuter-project',
    storageBucket: 'mynote-fluuter-project.appspot.com',
    iosClientId: '659854626505-p9dv5qrsffe4ksobp8evvtnbcl035cdg.apps.googleusercontent.com',
    iosBundleId: 'com.cyafard',
  );
}
