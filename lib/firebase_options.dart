import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSlmCJgFHG5m44jAOQgwd0oe8UM8MXk9g',
    appId: '1:413892751641:android:0ccd206b06cd335f45d588',
    messagingSenderId: '413892751641',
    projectId: 'hisabi-63ab4',
    storageBucket: 'hisabi-63ab4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBwRa4ZUiJP18LpSiFa8Q5wKUmG4pywnrc',
    appId: '1:413892751641:ios:0b5805179d00292845d588',
    messagingSenderId: '413892751641',
    projectId: 'hisabi-63ab4',
    storageBucket: 'hisabi-63ab4.firebasestorage.app',
    iosBundleId: 'com.farhanhasan.hisabi',
  );
}
