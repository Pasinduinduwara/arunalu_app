import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for ${defaultTargetPlatform.toString()}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdcUPuPRpLQRboh5-A4m-xs9DsFy6n098',
    appId: '1:535834969829:android:55d1c60eee0836ef83b60c',
    messagingSenderId: '535834969829',
    projectId: 'arunalu-d024d',
    storageBucket: 'arunalu-d024d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdcUPuPRpLQRboh5-A4m-xs9DsFy6n098',
    appId: '1:535834969829:ios:55d1c60eee0836ef83b60c',
    messagingSenderId: '535834969829',
    projectId: 'arunalu-d024d',
    storageBucket: 'arunalu-d024d.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDdcUPuPRpLQRboh5-A4m-xs9DsFy6n098',
    appId: '1:535834969829:web:55d1c60eee0836ef83b60c',
    messagingSenderId: '535834969829',
    projectId: 'arunalu-d024d',
    storageBucket: 'arunalu-d024d.appspot.com',
    authDomain: 'arunalu-d024d.firebaseapp.com',
  );
} 