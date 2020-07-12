import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/screens/Account/account.dart';
import 'package:Medicall/screens/Account/payment_detail.dart';
import 'package:Medicall/screens/ConfirmConsult/index.dart';
import 'package:Medicall/screens/Consent/index.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/History/Detail/index.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/Login/login.dart';
import 'package:Medicall/screens/MakePayment/make_payment.dart';
import 'package:Medicall/screens/Malpractice/malpractice.dart';
import 'package:Medicall/screens/OCR/Congrats.dart';
import 'package:Medicall/screens/OCR/OCRScreen.dart';
import 'package:Medicall/screens/PasswordReset/index.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/screens/Privacy/index.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:Medicall/screens/Questions/questions_screen.dart';
import 'package:Medicall/screens/Registration/Provider/consult_detail_screen.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration.dart';
import 'package:Medicall/screens/Registration/photoIdScreen.dart';
import 'package:Medicall/screens/Registration/registration.dart';
import 'package:Medicall/screens/Registration/registrationType.dart';
import 'package:Medicall/screens/SelectProvider/provider_detail.dart';
import 'package:Medicall/screens/SelectProvider/select_provider.dart';
import 'package:Medicall/screens/Symptoms/symptom_detail.dart';
import 'package:Medicall/screens/Symptoms/symptoms.dart';
import 'package:Medicall/screens/Terms/index.dart';
import 'package:Medicall/screens/Welcome//welcome.dart';
import 'package:Medicall/screens/Welcome/start_visit.dart';
import 'package:Medicall/screens/Welcome/zip_code_verify.dart';
import 'package:flutter/material.dart';

class Routes {
  static const login = '/login';
  static const phoneAuth = '/phone-auth';
  static const registrationType = '/registration-type';
  static const welcome = '/welcome';
  static const startVisit = '/start-visit';
  static const zipCodeVerify = '/zip-code-verify';
  static const registration = '/registration';
  static const providerRegistration = '/provider-registration';
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
  static const symptomDetail = '/symptoms-detail';
  static const questions = '/questions';
  static const selectProvider = '/select-provider';
  static const providerDetail = '/provider-detail';
  static const consultReview = '/consult-review';
  static const makePayment = '/make-payment';
  static const history = '/history';
  static const historyDetail = '/history-detail';
  static const account = '/account';
  static const paymentDetail = '/payment-detail';
  static const providerDashboard = '/provider-dashboard';
  static const consultDetail = '/consult-detail';
}

class Router {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute<dynamic>(
          builder: (context) => LoginScreen.create(context),
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
      case Routes.welcome:
        return MaterialPageRoute<dynamic>(
          builder: (context) => WelcomeScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.startVisit:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => StartVisitScreen(
            consult: consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.zipCodeVerify:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ZipCodeVerifyScreen.create(context, symptom),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.registration:
        return MaterialPageRoute<dynamic>(
          builder: (context) => RegistrationScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.providerRegistration:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderRegistrationScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/reset_password':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PasswordResetScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/photoID':
        return MaterialPageRoute<dynamic>(
          builder: (context) => PhotoIdScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/ocr':
        return MaterialPageRoute<dynamic>(
          builder: (context) => OCRScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.personalInfo:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => PersonalInfoScreen.create(context, consult),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/congrats':
        return MaterialPageRoute<dynamic>(
          builder: (context) => CongratsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.dashboard:
        return MaterialPageRoute<dynamic>(
          builder: (context) => DashboardScreen.create(context),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.terms:
        return MaterialPageRoute<dynamic>(
          builder: (context) => TermsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.privacy:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PrivacyScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.consent:
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
      case Routes.symptoms:
        return MaterialPageRoute<dynamic>(
          builder: (context) => SymptomsScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.symptomDetail:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        return MaterialPageRoute<dynamic>(
          builder: (_) => SymptomDetailScreen(symptom: symptom),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.questions:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => QuestionsScreen.create(
            context,
            consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case '/questionsScreen':
        return MaterialPageRoute<dynamic>(
          builder: (context) => QuestionsScreenOld(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.selectProvider:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => SelectProviderScreen(symptom: symptom),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.providerDetail:
        final Map<String, dynamic> mapArgs = args;
        final Symptom symptom = mapArgs['symptom'];
        final ProviderUser provider = mapArgs['provider'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderDetailScreen(
            symptom: symptom,
            provider: provider,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.providerDashboard:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        final ProviderUser provider = mapArgs['provider'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => ProviderDashboardScreen(),
          settings: settings,
          fullscreenDialog: true,
        );

      case Routes.consultDetail:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (_) => ConsultDetailScreen(
            consult: consult,
          ),
          settings: settings,
          fullscreenDialog: true,
        );

      case '/consultReview':
        return MaterialPageRoute<dynamic>(
          builder: (context) => ConfirmConsultScreen(),
          settings: settings,
          fullscreenDialog: true,
        );
      case Routes.makePayment:
        final Map<String, dynamic> mapArgs = args;
        final Consult consult = mapArgs['consult'];
        return MaterialPageRoute<dynamic>(
          builder: (context) => MakePayment.create(context, consult),
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
          builder: (context) => PaymentDetail.create(context),
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
