import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Medicall/util/app_util.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;

  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var msg = message.values.first
            .toString()
            .replaceAll('{title: ', '')
            .replaceAll(', body: ', '\n \n')
            .replaceAll('\}', '');

        AppUtil().showAlert('\n \n    ' + msg + '\n \n');
        print('onMessage: $message');
        //_showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        //_navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      //print('Settings registered: $settings');
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print(token);
    });
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      //print('Settings registered: $settings');
    });
  }
}
