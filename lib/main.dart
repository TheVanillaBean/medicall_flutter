import 'dart:io';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/landing_page/auth_widget_builder.dart';
import 'package:Medicall/screens/landing_page/landing_page.dart';
import 'package:Medicall/screens/landing_page/version_checker.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_details_overview.dart';
import 'package:Medicall/screens/provider_flow/account/provider_account.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_overview.dart';
import 'package:Medicall/screens/shared/chat/chat_screen.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/theme.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/user/user_model_base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appleSignInAvailable = await AppleSignInAvailable.check();
  runApp(MedicallApp(
    appleSignInAvailable: appleSignInAvailable,
    authServiceBuilder: (_) => Auth(),
    databaseBuilder: (_) => NonAuthFirestoreDB(),
    tempUserProvider: (_) => TempUserProvider(),
  ));
}

class MedicallApp extends StatelessWidget {
  final AppleSignInAvailable appleSignInAvailable;
  final AuthBase Function(BuildContext context) authServiceBuilder;
  final NonAuthDatabase Function(BuildContext context) databaseBuilder;
  final TempUserProvider Function(BuildContext context) tempUserProvider;

  const MedicallApp({
    Key key,
    this.appleSignInAvailable,
    this.authServiceBuilder,
    this.databaseBuilder,
    this.tempUserProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        Provider<AppleSignInAvailable>.value(
          value: appleSignInAvailable,
        ),
        Provider<AuthBase>(
          create: authServiceBuilder,
        ),
        Provider<TempUserProvider>(
          create: tempUserProvider,
        ),
        Provider<NonAuthDatabase>(
          create: databaseBuilder,
        ),
        Provider<StripeProviderBase>(
          create: (_) => StripeProvider(),
        ),
        Provider<ExtImageProvider>(
          create: (_) => ExtendedImageProvider(),
        ),
        Provider<FirebaseNotifications>(
          create: (_) => FirebaseNotifications(),
        ),
      ],
      child: AuthWidgetBuilder(
        userProvidersBuilder: (_, user) => [
          Provider<UserProvider>(
            create: (_) => UserProvider(user: user),
          ),
          Provider<FirestoreDatabase>(
            create: (_) => FirestoreDatabase(),
          ),
          Provider<FirebaseStorageService>(
            create: (_) => FirebaseStorageService(uid: user.uid),
          ),
          Provider<ChatProvider>(
            create: (_) => ChatProvider(),
          ),
        ],
        builder: (context, userSnapshot) {
          TempUserProvider tempUserProvider =
              Provider.of<TempUserProvider>(context);
          setStatusBarColor();
          return MaterialApp(
            title: 'Medicall',
            debugShowCheckedModeBanner: false,
            theme: myTheme,
            home: VersionChecker(
              pushNotificationHandler: (context) =>
                  FirebaseNotificationsHandler(
                landingPageBuilder: (context) => LandingPage(
                  userSnapshot: userSnapshot,
                  nonSignedInBuilder: (context) => WelcomeScreen(),
                  signedInBuilder: (context) =>
                      userSnapshot.data.type == USER_TYPE.PROVIDER
                          ? ProviderDashboardScreen.create(context)
                          : PatientDashboardScreen.create(context),
                  providerPhotoBuilder: (context) => ProviderAccountScreen(),
                  startVisitBuilder: (context) => StartVisitScreen(
                    consult: tempUserProvider.consult,
                  ),
                ),
              ),
            ),
            onGenerateRoute: Router.onGenerateRoute,
          );
        },
      ),
    );
  }
}

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
        _serialiseAndNavigate(message);
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

  Future<void> _serialiseAndNavigate(Map<String, dynamic> message) async {
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
          VisitDetailsOverview.show(context: context, consult: consult);
        }
      } else if (screen == 'Visit Overview') {
        // the user type for this screen should always be a provider, but just a check
        if (userType == USER_TYPE.PROVIDER &&
            userProvider.user.type == USER_TYPE.PROVIDER) {
          VisitOverview.show(
              context: context,
              consultId: consultId,
              patientUser: consult.patientUser);
        }
      } else if (screen == 'Chat') {
        navigateToChatScreen(consult: consult);
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
