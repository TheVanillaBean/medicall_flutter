import 'package:flutter/material.dart';
import 'styles.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import '../../presentation/medicall_app_icons.dart' as CustomIcons;
import '../../globals.dart' as globals;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  //AnimationController _loginButtonController;
  var animationStatus = 0;
  GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    super.initState();
    // _loginButtonController = new AnimationController(
    //     duration: new Duration(milliseconds: 3000), vsync: this);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        globals.currentUser = account;
      });
      if (globals.currentUser != null) {
        //_handleGetContact();
      }
    });
    //_googleSignIn.signInSilently();
  }

  @override
  void dispose() {
    //_loginButtonController.dispose();
    super.dispose();
  }

  // Future<Null> _playAnimation() async {
  //   try {
  //     await _loginButtonController.forward();
  //     await _loginButtonController.reverse();
  //   } on TickerCanceled {}
  // }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      Navigator.pushNamed(context, '/home');
      //animationStatus = 1;
      //_playAnimation();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return new Scaffold(
        body: new Container(
            decoration: new BoxDecoration(
              image: backgroundImage,
            ),
            child: new Container(
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                  colors: <Color>[
                    const Color.fromRGBO(35, 179, 232, 0.8),
                    const Color.fromRGBO(50, 50, 50, 1),
                  ],
                  stops: [0.2, 1.0],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                )),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Column(
                            
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: new Icon(CustomIcons.MedicallApp.logo_m,
                                  size: 45.0, color: Color.fromRGBO(255, 255, 255, 0.6)),
                              )
                            ],
                          ),
                          new Column(
                            children: <Widget>[
                              new Text('Medicall',
                                  style: TextStyle(
                                      fontSize: 24.0,
                                      letterSpacing: 1.5,
                                      color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    new Expanded(
                      flex: 1,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GoogleSignInButton(
                              onPressed: () {
                                setState(() {
                                  //animationStatus = 1;
                                  _handleSignIn();
                                });
                              },
                              darkMode: true)
                        ],
                      ),
                    )
                  ],
                ))));
  }
}

// child: new Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     new Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: <Widget>[
//                         new Column(
//                           children: <Widget>[
//                             new Icon(CustomIcons.MedicallApp.logo,
//                                 size: 45.0, color: Colors.white),
//                           ],
//                         ),
//                         new Column(
//                           children: <Widget>[
//                             new Text('Medicall',
//                                 style: TextStyle(
//                                     fontSize: 24.0,
//                                     letterSpacing: 1.5,
//                                     color: Colors.white)),
//                           ],
//                         ),
//                       ],
//                     ),
//                     new Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           GoogleSignInButton(
//                             onPressed: () {
//                               setState(() {
//                                 //animationStatus = 1;
//                                 _handleSignIn();
//                               });
//                             },
//                             darkMode: true)
//                         ],
//                     )],
//                 ))));
