import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/landing_page/auth_widget_builder.dart';
import 'package:Medicall/screens/landing_page/landing_page.dart';
import 'package:Medicall/screens/landing_page/version_checker.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/screens/provider_flow/account/provider_account.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard.dart';
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
import 'package:firebase_core/firebase_core.dart';
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
            onGenerateRoute: Router.onGenerateRoute,
          );
        },
      ),
    );
  }
}
