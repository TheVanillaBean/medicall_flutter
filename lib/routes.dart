import 'package:flutter/material.dart';
import 'package:medicall/screens/Login/index.dart';
import 'package:medicall/screens/Home/index.dart';
import 'package:medicall/screens/Doctors/index.dart';
import 'package:medicall/screens/Questions/questions_manager.dart';
import 'package:medicall/screens/Chat/index.dart';
import 'package:medicall/screens/History/index.dart';
import 'package:medicall/screens/Settings/index.dart';

class Routes {
  Routes() {
    runApp(new MaterialApp(
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
            case '/questions':
            return new MyCustomRoute(
              builder: (_) => new QuestionsManager('',''),
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
    ));
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  
}
