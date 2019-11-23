import 'dart:async';

import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/screens/Account/paymentDetail.dart';
import 'package:Medicall/screens/Chat/index.dart';
import 'package:Medicall/screens/ConfirmConsult/index.dart';
import 'package:Medicall/screens/Consent/index.dart';
import 'package:Medicall/screens/Doctors/index.dart';
import 'package:Medicall/screens/History/historyDetail.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/Home/index.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/OtpVerification/index.dart';
import 'package:Medicall/screens/Privacy/index.dart';
import 'package:Medicall/screens/Questions/medicalHistory.dart';
import 'package:Medicall/screens/Questions/symptomScreening.dart';
import 'package:Medicall/screens/QuestionsUpload/index.dart';
import 'package:Medicall/screens/Registration/RegistrationType/index.dart';
import 'package:Medicall/screens/Registration/index.dart';
import 'package:Medicall/screens/SelectProvider/index.dart';
import 'package:Medicall/screens/Account/index.dart';
import 'package:Medicall/screens/Terms/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:oktoast/oktoast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() async {
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

const Color background = Color(0xFFFFFFFF);
const Color primaryColor = Color.fromRGBO(29, 164, 204, 1);
const Color onPrimary = Color(0xFFFFFFFF);
const Color primaryVariant = Color(0xFF48ACF0);
const Color secondaryColor = Color.fromRGBO(241, 100, 119, 1);
const Color onSecondary = Color(0xFF0E202C);
const Color onSurface = Color.fromRGBO(33, 136, 181, 1);

const Color secondaryVariant = Color(0xFF47E5BC);
const Color accentColor = Color.fromRGBO(241, 100, 119, 1);
final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
  primary: primaryColor,
  onPrimary: onPrimary,
  background: background,
  onSurface: onSurface,
  secondary: secondaryColor,
  onSecondary: onSecondary,
  primaryVariant: primaryVariant,
  secondaryVariant: secondaryVariant,
);

class _MedicallAppState extends State<MedicallApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Medicall',
        debugShowCheckedModeBanner: false,
        navigatorKey: GlobalNavigatorKey.key,
        navigatorObservers: <NavigatorObserver>[observer],
        theme: ThemeData(
            primaryColor: primaryColor,
            accentColor: accentColor,
            colorScheme: colorScheme,
            canvasColor: Color.fromRGBO(29, 164, 204, 1),
            buttonTheme: ButtonThemeData(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(0.0)),
            ),
            highlightColor: Color.fromRGBO(35, 179, 232, 0),
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: Theme.of(context).colorScheme.onPrimary,
            toggleableActiveColor: Color.fromRGBO(241, 100, 119, 1),
            textSelectionColor: Color.fromRGBO(241, 100, 119, 0.5),
            textSelectionHandleColor: Color.fromRGBO(35, 179, 232, 1),
            cursorColor: Color.fromRGBO(35, 179, 232, 1),
            // inputDecorationTheme: InputDecorationTheme(
            //   border: const OutlineInputBorder(
            //     borderSide: BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
            //   ),
            //   enabledBorder: OutlineInputBorder(
            //     borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            //   ),
            //   focusedBorder: const OutlineInputBorder(
            //     borderSide: BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
            //   ),
            //   labelStyle: const TextStyle(
            //     color: Color.fromRGBO(35, 179, 232, 1),
            //   ),
            // ),
            backgroundColor: Theme.of(context).colorScheme.onPrimary),
        home: LoginPage(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/login':
              return MyCustomRoute(
                builder: (_) => LoginPage(),
                settings: settings,
              );
            case '/verification':
              return MyCustomRoute(
                builder: (_) => OtpVerificationScreen(),
                settings: settings,
              );
            case '/registrationType':
              return MyCustomRoute(
                builder: (_) => RegistrationTypeScreen(),
                settings: settings,
              );
            case '/registration':
              return MyCustomRoute(
                builder: (_) => RegistrationScreen(data: settings.arguments),
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
            case '/home':
              return MyCustomRoute(
                builder: (_) => HomeScreen(),
                settings: settings,
              );
            case '/doctors':
              return MyCustomRoute(
                builder: (_) => DoctorsScreen(data: settings.arguments),
                settings: settings,
              );
            case '/questionsScreening':
              return MyCustomRoute(
                builder: (_) =>
                    SymptomQuestionsScreen(data: settings.arguments),
                settings: settings,
              );
            case '/selectProvider':
              return MyCustomRoute(
                builder: (_) => SelectProviderScreen(data: settings.arguments),
                settings: settings,
              );
            case '/questionsHistory':
              return MyCustomRoute(
                builder: (_) => MedHistoryQuestionsScreen(
                  data: settings.arguments,
                ),
                settings: settings,
              );
            case '/questionsUpload':
              return MyCustomRoute(
                builder: (_) => QuestionsUploadScreen(data: settings.arguments),
                settings: settings,
              );
            case '/chat':
              return MyCustomRoute(
                builder: (_) => ChatScreen(),
                settings: settings,
              );
            case '/consultReview':
              return MyCustomRoute(
                builder: (_) => ConfirmConsultScreen(data: settings.arguments),
                settings: settings,
              );
            case '/history':
              return MyCustomRoute(
                builder: (_) => HistoryScreen(data: settings.arguments),
                settings: settings,
              );
            case '/historyDetail':
              return MyCustomRoute(
                builder: (_) => HistoryDetailScreen(data: settings.arguments),
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
            builder: (_) => LoginPage(),
            settings: settings,
          );
        },
      ),
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
}
