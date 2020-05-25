import 'dart:async';

import 'package:Medicall/common_widgets/carousel/carousel_state.dart';
import 'package:Medicall/screens/Account/index.dart';
import 'package:Medicall/screens/Account/paymentDetail.dart';
import 'package:Medicall/screens/ConfirmConsult/index.dart';
import 'package:Medicall/screens/Consent/index.dart';
import 'package:Medicall/screens/History/Detail/index.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/LandingPage/auth_widget_builder.dart';
import 'package:Medicall/screens/LandingPage/index.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/GetStarted/index.dart';
import 'package:Medicall/screens/GetStarted/zipCodeVerify.dart';
import 'package:Medicall/screens/Malpractice/malpractice.dart';
import 'package:Medicall/screens/PasswordReset/index.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/screens/Privacy/index.dart';
import 'package:Medicall/screens/Registration/index.dart';
import 'package:Medicall/screens/Registration/photoIdScreen.dart';
import 'package:Medicall/screens/Registration/registrationType.dart';
import 'package:Medicall/screens/SelectProvider/index.dart';
import 'package:Medicall/screens/SelectProvider/providerDetail.dart';
import 'package:Medicall/screens/Symptoms/medical_history_state.dart';
import 'package:Medicall/screens/Terms/index.dart';
import 'package:Medicall/services/animation_provider.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/flare_provider.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/theme.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:provider/provider.dart';

import 'screens/Questions/questionsScreen.dart';
import 'screens/Symptoms/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isInDebugMode = false;
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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

  final appleSignInAvailable = await AppleSignInAvailable.check();
  runZoned(() {
    runApp(Provider<AppleSignInAvailable>.value(
      value: appleSignInAvailable,
      child: MedicallApp(),
    ));
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

class MedicallApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.values[0]]);
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MultiProvider(
      providers: [
        Provider<AuthBase>(
          create: (_) => Auth(),
        ),
        Provider<ExtImageProvider>(
          create: (_) => ExtendedImageProvider(),
        ),
        Provider<MyStripeProvider>(
          create: (_) => MyStripeProvider(),
        ),
        Provider<Database>(
          create: (_) => FirestoreDatabase(),
        ),
        Provider<MyAnimationProvider>(
          create: (_) => MyAnimationProvider(),
        ),
        Provider<MyFlareProvider>(
          create: (_) => MyFlareProvider(),
        ),
        ChangeNotifierProvider<CarouselState>(
          create: (_) => CarouselState(),
        ),
        ChangeNotifierProvider<MedicalHistoryState>(
          create: (_) => MedicalHistoryState(),
        ),
      ],
      child: _buildApp(),
    );
  }

  AuthWidgetBuilder _buildApp() {
    return AuthWidgetBuilder(
      builder: (context, userSnapshot) {
        return MaterialApp(
          title: 'Medicall',
          debugShowCheckedModeBanner: false,
          theme: myTheme,
          home: LandingPage(userSnapshot: userSnapshot),
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/login':
                return MyCustomRoute(
                  builder: (_) => LoginPage.create(context),
                  settings: settings,
                );
              case '/phoneAuth':
                return MyCustomRoute(
                  builder: (_) => PhoneAuthScreen.create(context),
                  settings: settings,
                );
              case '/registrationType':
                return MyCustomRoute(
                  builder: (_) => RegistrationTypeScreen(),
                  settings: settings,
                );
              case '/getStarted':
                return MyCustomRoute(
                  builder: (_) => GetStartedScreen(),
                  settings: settings,
                );
              case '/zipCodeVerify':
                return MyCustomRoute(
                  builder: (_) => ZipCodeVerifyScreen(),
                  settings: settings,
                );
              case '/registration':
                return MyCustomRoute(
                  builder: (_) => RegistrationScreen(),
                  settings: settings,
                );
              case '/reset_password':
                return MyCustomRoute(
                  builder: (_) => PasswordResetScreen.create(context),
                  settings: settings,
                );
              case '/photoID':
                return MyCustomRoute(
                  builder: (_) => PhotoIdScreen.create(context),
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
              case '/malpractice':
                return MyCustomRoute(
                  builder: (_) => MalpracticeScreen.create(context),
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
                  builder: (_) => SelectProviderScreen(),
                  settings: settings,
                );
              case '/providerDetail':
                return MyCustomRoute(
                  builder: (_) => ProviderDetailScreen(),
                  settings: settings,
                );
              case '/consultReview':
                return MyCustomRoute(
                  builder: (_) => ConfirmConsultScreen(),
                  settings: settings,
                );
              case '/history':
                return MyCustomRoute(
                  builder: (_) => HistoryScreen.create(context, true, ''),
                  settings: settings,
                );
              case '/historyDetail':
                return MyCustomRoute(
                  builder: (_) => HistoryDetailScreen.create(context),
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
              default:
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(
                      child: Text('No route defined for ${settings.name}'),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
}
