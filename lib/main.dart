import 'dart:async';

import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/screens/Account/index.dart';
import 'package:Medicall/screens/Account/paymentDetail.dart';
import 'package:Medicall/screens/Chat/index.dart';
import 'package:Medicall/screens/ConfirmConsult/index.dart';
import 'package:Medicall/screens/Consent/index.dart';
import 'package:Medicall/screens/History/historyDetail.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/LandingPage/index.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/Privacy/index.dart';
import 'package:Medicall/screens/QuestionsUpload/index.dart';
import 'package:Medicall/screens/Registration/index.dart';
import 'package:Medicall/screens/Registration/registrationType.dart';
import 'package:Medicall/screens/SelectProvider/index.dart';
import 'package:Medicall/screens/Terms/index.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'screens/Questions/questionsScreen.dart';
import 'screens/Symptoms/index.dart';
import 'services/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isInDebugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    runApp(MedicallApp());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MedicallApp extends StatefulWidget {
  MedicallApp({Key key}) : super(key: key);

  _MedicallAppState createState() => _MedicallAppState();
}

class _MedicallAppState extends State<MedicallApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBase>(create: (_) => Auth()),
        Provider<Database>(create: (_) => FirestoreDatabase()),
      ],
      child: Consumer<AuthBase>(
        builder: (ctx, auth, _) => OKToast(
          child: MaterialApp(
            title: 'Medicall',
            debugShowCheckedModeBanner: false,
            navigatorKey: GlobalNavigatorKey.key,
            navigatorObservers: <NavigatorObserver>[observer],
            theme: myTheme,
            home: LandingPage(),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/login':
                  return MyCustomRoute(
                    builder: (_) => LoginPage.create(context),
                    settings: settings,
                  );
                case '/registrationType':
                  return MyCustomRoute(
                    builder: (_) => RegistrationTypeScreen(),
                    settings: settings,
                  );
                case '/registration':
                  return MyCustomRoute(
                    builder: (_) => RegistrationScreen(),
                    settings: settings,
                  );
                case '/terms':
                  return MyCustomRoute(
                    builder: (_) => TermsScreen(),
                    settings: settings,
                  );
                case '/privacy':
                  return MyCustomRoute(
                    builder: (_) => PrivacyScreen(),
                    settings: settings,
                  );
                case '/consent':
                  return MyCustomRoute(
                    builder: (_) => ConsentScreen(),
                    settings: settings,
                  );
                case '/symptoms':
                  return MyCustomRoute(
                    builder: (_) => SymptomsScreen(),
                    settings: settings,
                  );
                case '/questionsScreen':
                  return MyCustomRoute(
                    builder: (_) => QuestionsScreen(),
                    settings: settings,
                  );
                case '/selectProvider':
                  return MyCustomRoute(
                    builder: (_) =>
                        SelectProviderScreen(),
                    settings: settings,
                  );
                case '/questionsUpload':
                  return MyCustomRoute(
                    builder: (_) =>
                        QuestionsUploadScreen(),
                    settings: settings,
                  );
                case '/consultReview':
                  return MyCustomRoute(
                    builder: (_) =>
                        ConfirmConsultScreen(),
                    settings: settings,
                  );
                case '/chat':
                  return MyCustomRoute(
                    builder: (_) => ChatScreen(),
                    settings: settings,
                  );
                case '/history':
                  return MyCustomRoute(
                    builder: (_) => HistoryScreen(),
                    settings: settings,
                  );
                case '/historyDetail':
                  return MyCustomRoute(
                    builder: (_) =>
                        HistoryDetailScreen(),
                    settings: settings,
                  );
                case '/account':
                  return MyCustomRoute(
                    builder: (_) => AccountScreen(),
                    settings: settings,
                  );
                case '/paymentDetail':
                  return MyCustomRoute(
                    builder: (_) => PaymentDetail(),
                    settings: settings,
                  );
              }
              return MyCustomRoute(
                builder: (_) => LandingPage(),
                settings: settings,
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
}
