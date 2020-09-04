import 'dart:io';

import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/patient_flow/account/patient_account.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseNotifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  MedicallUser _medicallUser;

  Future<void> initFirebaseNotifications(
      {@required MedicallUser medicallUser}) async {
    this._medicallUser = medicallUser;
    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }


  void _serialiseAndNavigate(Map<String, dynamic> message) {
    var notificationData = message['data'];
    var view = notificationData['view'];

    if (view != null) {
      if (view == 'create_post') {
        PatientAccountScreen.show(context: )
      }
    }
  }

  void _navigateToItemHistoryDetailOnLaunch(data) async {
    //var decodedUser = json.decode(data['data'].toString());
    var item = data['screen'].split('/');
    final String requestedRoute = item.toString();
    print('this is the requested route on launch:' + requestedRoute);
    //Navigator.pushReplacementNamed(scaffoldKey, '/login');
    //showToast('LAUNCH:' + item.toString(), duration: Duration(seconds: 3));
  }

  void _navigateToItemHistoryDetailOnResume(data) async {
    //var decodedUser = json.decode(data['data'].toString());
    var item = data['screen'].split('/');
    final String requestedRoute = item.toString();
    //Navigator.pushReplacementNamed(scaffoldKey, '/login');

    //showToast('RESUME:' + item.toString(), duration: Duration(seconds: 3));
    print('Navigate to this requested route:' + requestedRoute);
    Builder(
      builder: (BuildContext context) {
        Navigator.of(context).pushNamed('/' + item[0], arguments: {
          'user': _medicallUser,
          'documentId': item[1],
          'isRouted': true
        });
        return;
      },
    );

    return;
  }
}
