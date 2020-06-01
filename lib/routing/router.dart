import 'package:flutter/material.dart';

class Routes {
  static const login = '/login';
  static const phoneAuth = '/phone-auth';
  static const registrationType = '/registration-type';
  static const getStarted = '/get-started';
  static const startVisit = '/start-visit';
  static const zipCodeVerify = '/zip-code-verify';
  static const registration = '/registration';
  static const reset_password = '/reset-password';
  static const photoID = '/photo-ID';
  static const ocr = '/ocr';
  static const personalInfo = '/personal-information';
  static const congrats = '/congratulations';
  static const dashboard = '/dashboard';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const consent = '/consent';
  static const malpractice = '/malpractice';
  static const symptoms = '/symptoms';
  static const questionsScreen = '/questions-screen';
  static const selectProvider = '/select-provider';
  static const providerDetail = '/provider-detail';
  static const consultReview = '/consult-review';
  static const history = '/history';
  static const historyDetail = '/history-detail';
  static const account = '/account';
  static const paymentDetail = '/payment-detail';
}

class Router {
//  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
//    final args = settings.arguments;
//    switch (settings.name) {
//      case '/login':
//        return MyCustomRoute(
//          builder: (_) => LoginPage.create(context),
//          settings: settings,
//        );
//      case '/phoneAuth':
//        return MyCustomRoute(
//          builder: (_) => PhoneAuthScreen.create(context, null),
//          settings: settings,
//        );
//      case '/registrationType':
//        return MyCustomRoute(
//          builder: (_) => RegistrationTypeScreen(),
//          settings: settings,
//        );
//      case '/getStarted':
//        return MyCustomRoute(
//          builder: (_) => GetStartedScreen(),
//          settings: settings,
//        );
//      case '/startVisit':
//        return MyCustomRoute(
//          builder: (_) => StartVisitScreen(),
//          settings: settings,
//        );
//      case '/zipCodeVerify':
//        return MyCustomRoute(
//          builder: (_) => ZipCodeVerifyScreen(),
//          settings: settings,
//        );
//      case '/registration':
//        return MyCustomRoute(
//          builder: (_) => RegistrationScreen(),
//          settings: settings,
//        );
//      case '/reset_password':
//        return MyCustomRoute(
//          builder: (_) => PasswordResetScreen.create(context),
//          settings: settings,
//        );
//      case '/photoID':
//        return MyCustomRoute(
//          builder: (_) => PhotoIdScreen.create(context),
//          settings: settings,
//        );
//      case '/ocr':
//        return MyCustomRoute(
//          builder: (_) => OCRScreen(),
//          settings: settings,
//        );
//      case '/personalInfo':
//        return MyCustomRoute(
//          builder: (_) => PersonalInfoScreen(),
//          settings: settings,
//        );
//      case '/congrats':
//        return MyCustomRoute(
//          builder: (_) => CongratsScreen(),
//          settings: settings,
//        );
//      case '/dashboard':
//        return MyCustomRoute(
//          builder: (_) => DashboardScreen.create(context),
//          settings: settings,
//        );
//      case '/terms':
//        return MyCustomRoute(
//          builder: (_) => TermsScreen(),
//          settings: settings,
//        );
//      case '/privacy':
//        return MyCustomRoute(
//          builder: (_) => PrivacyScreen(),
//          settings: settings,
//        );
//      case '/consent':
//        return MyCustomRoute(
//          builder: (_) => ConsentScreen(),
//          settings: settings,
//        );
//      case '/malpractice':
//        return MyCustomRoute(
//          builder: (_) => MalpracticeScreen.create(context),
//          settings: settings,
//        );
//      case '/symptoms':
//        return MyCustomRoute(
//          builder: (_) => SymptomsScreen(),
//          settings: settings,
//        );
//      case '/questionsScreen':
//        return MyCustomRoute(
//          builder: (_) => QuestionsScreen(),
//          settings: settings,
//        );
//      case '/selectProvider':
//        return MyCustomRoute(
//          builder: (_) => SelectProviderScreen(),
//          settings: settings,
//        );
//      case '/providerDetail':
//        return MyCustomRoute(
//          builder: (_) => ProviderDetailScreen(),
//          settings: settings,
//        );
//      case '/consultReview':
//        return MyCustomRoute(
//          builder: (_) => ConfirmConsultScreen(),
//          settings: settings,
//        );
//      case '/history':
//        return MyCustomRoute(
//          builder: (_) => HistoryScreen.create(context, true, ''),
//          settings: settings,
//        );
//      case '/historyDetail':
//        return MyCustomRoute(
//          builder: (_) => HistoryDetailScreen.create(context),
//          settings: settings,
//        );
//      case '/account':
//        return MyCustomRoute(
//          builder: (_) => AccountScreen(),
//          settings: settings,
//        );
//      case '/paymentDetail':
//        return MyCustomRoute(
//          builder: (_) => PaymentDetail(),
//          settings: settings,
//        );
//      default:
//        return MaterialPageRoute(
//          builder: (_) => Scaffold(
//            body: Center(
//              child: Text('No route defined for ${settings.name}'),
//            ),
//          ),
//        );
//    }
//  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
}
