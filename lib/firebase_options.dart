// File generated manually based on google-services.json for dhanda-app-c873f.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB67Oc6AC1hinLiMtJF_HdH5rrZ49sghaQ',
    appId: '1:1290657485:android:4056e914837bac9c3d9384',
    messagingSenderId: '1290657485',
    projectId: 'dhanda-app-c873f',
    storageBucket: 'dhanda-app-c873f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB67Oc6AC1hinLiMtJF_HdH5rrZ49sghaQ',
    appId: '1:1290657485:android:4056e914837bac9c3d9384',
    messagingSenderId: '1290657485',
    projectId: 'dhanda-app-c873f',
    storageBucket: 'dhanda-app-c873f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB67Oc6AC1hinLiMtJF_HdH5rrZ49sghaQ',
    appId: '1:1290657485:android:4056e914837bac9c3d9384',
    messagingSenderId: '1290657485',
    projectId: 'dhanda-app-c873f',
    storageBucket: 'dhanda-app-c873f.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB67Oc6AC1hinLiMtJF_HdH5rrZ49sghaQ',
    appId: '1:1290657485:android:4056e914837bac9c3d9384',
    messagingSenderId: '1290657485',
    projectId: 'dhanda-app-c873f',
    storageBucket: 'dhanda-app-c873f.firebasestorage.app',
  );
}
