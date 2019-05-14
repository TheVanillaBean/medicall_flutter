import 'package:flutter/material.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/Home/index.dart';
import 'package:Medicall/screens/Doctors/index.dart';
import 'package:Medicall/screens/QuestionsScreening/index.dart';
import 'package:Medicall/screens/SelectProvider/index.dart';
import 'package:Medicall/screens/QuestionsHistory/index.dart';
import 'package:Medicall/screens/QuestionsUpload/index.dart';
import 'package:Medicall/screens/Chat/index.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/Settings/index.dart';
import 'package:Medicall/screens/Registration/Provider/index.dart';
import 'package:Medicall/screens/Registration/Patient/index.dart';
import 'package:Medicall/screens/OtpVerification/index.dart';
import 'package:Medicall/screens/Terms/index.dart';
import 'package:Medicall/screens/Privacy/index.dart';
import 'package:oktoast/oktoast.dart';

// import 'package:Medicall/mutations/addStar.dart' as mutations;
// import 'package:Medicall/queries/readRepositories.dart' as queries;

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
}

class Routes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
          title: 'Medicall',
          debugShowCheckedModeBanner: false,
          theme: new ThemeData(
              highlightColor: Color.fromRGBO(35, 179, 232, 0),
              splashColor: Colors.transparent,
              scaffoldBackgroundColor: Colors.white,
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
              backgroundColor: Colors.white),
          home: new LoginPage(),
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/login':
                return new MyCustomRoute(
                  builder: (_) => new LoginPage(),
                  settings: settings,
                );
              case '/verification':
                return new MyCustomRoute(
                  builder: (_) => new OtpVerificationScreen(),
                  settings: settings,
                );
              case '/registrationProvider':
                return new MyCustomRoute(
                  builder: (_) => new RegistrationProviderScreen(),
                  settings: settings,
                );
              case '/registrationPatient':
                return new MyCustomRoute(
                  builder: (_) => new RegistrationPatientScreen(),
                  settings: settings,
                );
              case '/terms':
                return new MyCustomRoute(
                  builder: (_) => new TermsScreen(),
                  settings: settings,
                );
              case '/privacy':
                return new MyCustomRoute(
                  builder: (_) => new PrivacyScreen(),
                  settings: settings,
                );
              case '/home':
                return new MyCustomRoute(
                  builder: (_) => new HomeScreen(),
                  settings: settings,
                );
              case '/doctors':
                return new MyCustomRoute(
                  builder: (_) => new DoctorsScreen(),
                  settings: settings,
                );
              case '/questionsScreening':
                return new MyCustomRoute(
                  builder: (_) => new QuestionsScreeningScreen(
                      consultType: settings.arguments),
                  settings: settings,
                );
              case '/selectProvider':
                return new MyCustomRoute(
                  builder: (_) =>
                      new SelectProviderScreen(questions: settings.arguments),
                  settings: settings,
                );
              case '/questionsHistory':
                return new MyCustomRoute(
                  builder: (_) => new QuestionsHistoryScreen(
                        selectedProvider: settings.arguments,
                      ),
                  settings: settings,
                );
              case '/questionsUpload':
                return new MyCustomRoute(
                  builder: (_) => new QuestionsUploadScreen(),
                  settings: settings,
                );
              case '/chat':
                return new MyCustomRoute(
                  builder: (_) => new ChatScreen(),
                  settings: settings,
                );
              case '/history':
                return new MyCustomRoute(
                  builder: (_) => new HistoryScreen(),
                  settings: settings,
                );
              case '/settings':
                return new MyCustomRoute(
                  builder: (_) => new SettingsScreen(),
                  settings: settings,
                );
            }
          },
          // routes: <String, WidgetBuilder> {
          //   '/about': (BuildContext context) => new _aboutPage.About(),
          // }
        ),
    );
  }
}
