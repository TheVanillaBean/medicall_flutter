import 'dart:io';

import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseUser firebaseUser;

  setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners();
  }

  _navigateToItemHistoryDetailOnLaunch(data) async {
    //var decodedUser = json.decode(data['data'].toString());
    var item = data['screen'].split('/');
    final SharedPreferences prefs = await _prefs;
    final String requestedRoute = item.toString();
    //Navigator.pushReplacementNamed(scaffoldKey, '/login');
    //showToast('LAUNCH:' + item.toString(), duration: Duration(seconds: 3));
    prefs.setString("requestedRoute", requestedRoute).then((bool success) {
      print('shared pref success');
    });
    return;
  }

  _navigateToItemHistoryDetailOnResume(data) async {
    //var decodedUser = json.decode(data['data'].toString());
    var item = data['screen'].split('/');
    final SharedPreferences prefs = await _prefs;
    final String requestedRoute = item.toString();
    //Navigator.pushReplacementNamed(scaffoldKey, '/login');

    //showToast('RESUME:' + item.toString(), duration: Duration(seconds: 3));
    prefs.setString("requestedRoute", requestedRoute).then((bool success) {
      print('shared pref success');
    });
    GlobalNavigatorKey.key.currentState.pushNamed('/' + item[0], arguments: {
      'user': medicallUser,
      'documentId': item[1],
      'isRouted': true
    });
    return;

    // showToast('RESUME:' + item.toString(), duration: Duration(seconds: 3));
    // prefs.setString("requestedRoute", requestedRoute).then((bool success) {
    //   print('shared pref success');
    // });
  }

  firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //AppUtil().showAlert('\n \n    ' + msg + '\n \n');
        print('onMessage: $message');
        //_showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _navigateToItemHistoryDetailOnLaunch(message['data']);
        //_navigateToItemDetail(message);
        //showToast('laucnhginhhhh', duration: Duration(seconds: 60));

        //(message['data']);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        if (medicallUser != null) {
          _navigateToItemHistoryDetailOnResume(message['data']);
        } else {
          _navigateToItemHistoryDetailOnLaunch(message['data']);
        }
        //_navigateToItemHistoryDetail(message['data']);
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
      //print(token);
      medicallUser = MedicallUser();
      medicallUser.devTokens = [token];
    });
  }

  iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      //print('Settings registered: $settings');
    });
  }
}
