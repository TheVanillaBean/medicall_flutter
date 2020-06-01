import 'package:Medicall/screens/Account/index.dart';
import 'package:Medicall/screens/Account/paymentDetail.dart';
import 'package:Medicall/screens/ConfirmConsult/index.dart';
import 'package:Medicall/screens/Consent/index.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/GetStarted/index.dart';
import 'package:Medicall/screens/GetStarted/startVisit.dart';
import 'package:Medicall/screens/GetStarted/zipCodeVerify.dart';
import 'package:Medicall/screens/History/Detail/index.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/Malpractice/malpractice.dart';
import 'package:Medicall/screens/OCR/Congrats.dart';
import 'package:Medicall/screens/OCR/OCRScreen.dart';
import 'package:Medicall/screens/OCR/PersonalInfoScreen.dart';
import 'package:Medicall/screens/PasswordReset/index.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/screens/Privacy/index.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:Medicall/screens/Registration/photoIdScreen.dart';
import 'package:Medicall/screens/Registration/registrationType.dart';
import 'package:Medicall/screens/SelectProvider/index.dart';
import 'package:Medicall/screens/SelectProvider/providerDetail.dart';
import 'package:Medicall/screens/Symptoms/index.dart';
import 'package:Medicall/screens/Terms/index.dart';
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
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute<dynamic>(
          builder: (context) => LoginPage.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/phoneAuth':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PhoneAuthScreen.create(context, null),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/registrationType':
        return MaterialPageRoute<dynamic>(
          builder: (context) => RegistrationTypeScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/getStarted':
        return MaterialPageRoute<dynamic>(
          builder: (context) => GetStartedScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/startVisit':
        return MaterialPageRoute<dynamic>(
          builder: (context) => StartVisitScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/zipCodeVerify':
        return MaterialPageRoute<dynamic>(
          builder: (context) => ZipCodeVerifyScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/registration':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PasswordResetScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/reset_password':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PhotoIdScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/photoID':
        return MaterialPageRoute<dynamic>(
          builder: (context) => OCRScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/ocr':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PersonalInfoScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/personalInfo':
        return MaterialPageRoute<dynamic>(
          builder: (context) => DashboardScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/congrats':
        return MaterialPageRoute<dynamic>(
          builder: (context) => CongratsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/dashboard':
        return MaterialPageRoute<dynamic>(
          builder: (context) => DashboardScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/terms':
        return MaterialPageRoute<dynamic>(
          builder: (context) => TermsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/privacy':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PrivacyScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/consent':
        return MaterialPageRoute<dynamic>(
          builder: (context) => ConsentScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/malpractice':
        return MaterialPageRoute<dynamic>(
          builder: (context) => MalpracticeScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/symptoms':
        return MaterialPageRoute<dynamic>(
          builder: (context) => SymptomsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/questionsScreen':
        return MaterialPageRoute<dynamic>(
          builder: (context) => QuestionsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/selectProvider':
        return MaterialPageRoute<dynamic>(
          builder: (context) => SelectProviderScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/providerDetail':
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderDetailScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/consultReview':
        return MaterialPageRoute<dynamic>(
          builder: (context) => ConfirmConsultScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/history':
        return MaterialPageRoute<dynamic>(
          builder: (context) => HistoryScreen.create(context, true, ''),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/historyDetail':
        return MaterialPageRoute<dynamic>(
          builder: (context) => HistoryDetailScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/account':
        return MaterialPageRoute<dynamic>(
          builder: (context) => AccountScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/paymentDetail':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PaymentDetail(),
          settings: settings,
          fullscreenDialog: true,
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
  }
}
