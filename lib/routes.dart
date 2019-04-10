import 'package:flutter/material.dart';
import 'package:medicall/screens/Login/index.dart';
import 'package:medicall/screens/Home/index.dart';
import 'package:medicall/screens/Doctors/index.dart';
import 'package:medicall/screens/QuestionsScreening/index.dart';
import 'package:medicall/screens/SelectProvider/index.dart';
import 'package:medicall/screens/QuestionsHistory/index.dart';
import 'package:medicall/screens/QuestionsUpload/index.dart';
import 'package:medicall/screens/Chat/index.dart';
import 'package:medicall/screens/History/index.dart';
import 'package:medicall/screens/Settings/index.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:medicall/mutations/addStar.dart' as mutations;
import 'package:medicall/queries/readRepositories.dart' as queries;

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);
}

class Routes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<Client> client = ValueNotifier(
      Client(
        endPoint: 'https://api.github.com/graphql',
        cache: InMemoryCache(),
        apiToken: 'f6585ebdd49702369bb3fd8140e1af9b4317259b',
      ),
    );
    return GraphqlProvider(
      client: client,
      child: CacheProvider(
          child: MaterialApp(
        title: 'Medicall',
        theme: new ThemeData(
            highlightColor: Color.fromRGBO(35, 179, 232, 0),
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: Colors.white,
            backgroundColor: Colors.white),
        home: new LoginScreen(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/login':
              return new MyCustomRoute(
                builder: (_) => new LoginScreen(),
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
                builder: (_) => new QuestionsScreeningScreen(),
                settings: settings,
              );
            case '/selectProvider':
              return new MyCustomRoute(
                builder: (_) => new SelectProviderScreen(),
                settings: settings,
              );
            case '/questionsHistory':
              return new MyCustomRoute(
                builder: (_) => new QuestionsHistoryScreen(),
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
      )),
    );
  }
  
}


