import 'dart:io';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_details_overview.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_overview.dart';
import 'package:Medicall/screens/shared/chat/chat_screen.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseNotificationsHandler extends StatefulWidget {
  final WidgetBuilder landingPageBuilder;

  const FirebaseNotificationsHandler({@required this.landingPageBuilder});

  @override
  _FirebaseNotificationsHandlerState createState() =>
      _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState
    extends State<FirebaseNotificationsHandler> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _serialiseAndNavigate(message, onMessage: true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _serialiseAndNavigate(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _serialiseAndNavigate(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.landingPageBuilder(context);
  }

  Future<void> _showFlushBar({String msg, Function onTap}) async {
    return Flushbar(
      message: msg,
      onTap: onTap,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: 8,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      routeColor: Colors.black.withAlpha(100),
      margin: EdgeInsets.all(5),
      routeBlur: 2.0,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  Future<void> _serialiseAndNavigate(Map<String, dynamic> message,
      {bool onMessage = false}) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    //keys are derived from cloud functions (push.ts and stream.ts)
    Map<dynamic, dynamic> data = message;
    //for android, the data fields are in a separate JSON object inside message
    //for ios, they are all contained in the same root message object
    if (Platform.isAndroid) {
      data = message['data'];
    }
    String userTypeRaw = data['user_type'] as String;
    String screen = data['screen'] as String;

    USER_TYPE userType;
    if (userTypeRaw != null) {
      userType = userTypeRaw.toUserTypeEnum();
    }

    if (screen != null) {
      String consultId = data['consult_id'] as String;
      Consult consult = await getConsult(consultId: consultId);
      if (screen == 'Visit Detail') {
        // the user type for this screen should always be patient, but just a check
        if (userType == USER_TYPE.PATIENT &&
            userProvider.user.type == USER_TYPE.PATIENT) {
          if (onMessage) {
            String msg = data['message'] as String;
            _showFlushBar(
              msg: msg,
              onTap: (_) =>
                  VisitDetailsOverview.show(context: context, consult: consult),
            );
          } else {
            VisitDetailsOverview.show(context: context, consult: consult);
          }
        }
      } else if (screen == 'Visit Overview') {
        // the user type for this screen should always be a provider, but just a check
        if (userType == USER_TYPE.PROVIDER &&
            userProvider.user.type == USER_TYPE.PROVIDER) {
          if (onMessage) {
            String msg = data['message'] as String;
            _showFlushBar(
              msg: msg,
              onTap: (_) => VisitOverview.show(
                  context: context,
                  consultId: consultId,
                  patientUser: consult.patientUser),
            );
          } else {
            VisitOverview.show(
                context: context,
                consultId: consultId,
                patientUser: consult.patientUser);
          }
        }
      } else if (screen == 'Chat') {
        if (onMessage) {
          String msg = data['message'] as String;
          _showFlushBar(
            msg: msg,
            onTap: (_) => navigateToChatScreen(consult: consult),
          );
        } else {
          navigateToChatScreen(consult: consult);
        }
      }
    }
  }

  Future<Consult> getConsult({String consultId}) async {
    FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);

    Consult consult = await database.consultStream(consultId: consultId).first;
    PatientUser patientUser =
        await database.userStream(USER_TYPE.PATIENT, consult.patientId).first;
    ProviderUser providerUser =
        await database.userStream(USER_TYPE.PROVIDER, consult.providerId).first;
    consult.patientUser = patientUser;
    consult.providerUser = providerUser;
    return consult;
  }

  void navigateToChatScreen({Consult consult}) async {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);

    final channel = chatProvider.client.channel('messaging', id: consult.uid);

    ChatScreen.show(
      context: context,
      channel: channel,
      consult: consult,
    );
  }
}
