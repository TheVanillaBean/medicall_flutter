// import 'package:flutter/material.dart';
// import 'styles.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:async';
// import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;
// import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
// import 'package:Medicall/globals.dart' as globals;

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key key}) : super(key: key);
//   @override
//   LoginScreenState createState() => new LoginScreenState();
// }

// class LoginScreenState extends State<LoginScreen>
//     with TickerProviderStateMixin {
//   //AnimationController _loginButtonController;
//   var animationStatus = 0;
//   GoogleSignIn _googleSignIn = new GoogleSignIn(
//     scopes: [
//       'email',
//       'https://www.googleapis.com/auth/contacts.readonly',
//     ],
//   );

//   @override
//   void initState() {
//     super.initState();
//     // _loginButtonController = new AnimationController(
//     //     duration: new Duration(milliseconds: 3000), vsync: this);
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//       setState(() {
//         globals.currentUser = account;
//       });
//       if (globals.currentUser != null) {
//         //_handleGetContact();
//       }
//     });
//     //_googleSignIn.signInSilently();
//   }

//   @override
//   void dispose() {
//     //_loginButtonController.dispose();
//     super.dispose();
//   }

//   // Future<Null> _playAnimation() async {
//   //   try {
//   //     await _loginButtonController.forward();
//   //     await _loginButtonController.reverse();
//   //   } on TickerCanceled {}
//   // }

//   Future<void> _handleSignIn() async {
//     try {
//       await _googleSignIn.signIn();
//       Navigator.pushNamed(context, '/registration');
//       //animationStatus = 1;
//       //_playAnimation();
//     } catch (error) {
//       print(error);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     timeDilation = 0.4;
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//     return new Scaffold(
//         body: new Container(
//             decoration: new BoxDecoration(
//               image: backgroundImage,
//             ),
//             child: new Container(
//                 decoration: new BoxDecoration(
//                     gradient: new LinearGradient(
//                   colors: <Color>[
//                     const Color.fromRGBO(35, 179, 232, 0.8),
//                     const Color.fromRGBO(50, 50, 50, 1),
//                   ],
//                   stops: [0.2, 1.0],
//                   begin: const FractionalOffset(0.0, 0.0),
//                   end: const FractionalOffset(0.0, 1.0),
//                 )),
//                 child: new Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     new Padding(
//                       padding: EdgeInsets.only(top: 80),
//                       child: new Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           new Column(

//                             children: <Widget>[
//                               new Padding(
//                                 padding: EdgeInsets.only(right: 10),
//                                 child: new Icon(CustomIcons.MedicallApp.logo_m,
//                                   size: 45.0, color: Color.fromRGBO(255, 255, 255, 0.6)),
//                               )
//                             ],
//                           ),
//                           new Column(
//                             children: <Widget>[
//                               new Text('Medicall',
//                                   style: TextStyle(
//                                       fontSize: 24.0,
//                                       letterSpacing: 1.5,
//                                       color: Colors.white)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     new Expanded(
//                       flex: 1,
//                       child: new Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           GoogleSignInButton(
//                               onPressed: () {
//                                 setState(() {
//                                   //animationStatus = 1;
//                                   _handleSignIn();
//                                 });
//                               },
//                               darkMode: true)
//                         ],
//                       ),
//                     )
//                   ],
//                 ))));
//   }
// }

// // child: new Column(
// //                   mainAxisAlignment: MainAxisAlignment.start,
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: <Widget>[
// //                     new Row(
// //                       mainAxisAlignment: MainAxisAlignment.start,
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: <Widget>[
// //                         new Column(
// //                           children: <Widget>[
// //                             new Icon(CustomIcons.MedicallApp.logo,
// //                                 size: 45.0, color: Colors.white),
// //                           ],
// //                         ),
// //                         new Column(
// //                           children: <Widget>[
// //                             new Text('Medicall',
// //                                 style: TextStyle(
// //                                     fontSize: 24.0,
// //                                     letterSpacing: 1.5,
// //                                     color: Colors.white)),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                     new Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                         children: <Widget>[
// //                           GoogleSignInButton(
// //                             onPressed: () {
// //                               setState(() {
// //                                 //animationStatus = 1;
// //                                 _handleSignIn();
// //                               });
// //                             },
// //                             darkMode: true)
// //                         ],
// //                     )],
// //                 ))));
import 'package:Medicall/screens/Login/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_google_util.dart';
import 'package:Medicall/util/firebase_listenter.dart';
import 'package:Medicall/util/firebase_phone_util.dart';
import 'package:Medicall/components/progress_hud.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:Medicall/screens/Registration/RegistrationType/index.dart';
import 'package:Medicall/screens/Auth/index.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage>
    implements FirebaseAuthListener {
  bool _isPhoneAuthEnable = false;
  bool _isGoogleAuthEnable = false;
  bool _isEmailAuthEnable = true;
  bool _isLoading = false;

  var data;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  //GlobalKey<FormBuilderState> _fbKey = GlobalKey();

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _teMobileEmail = TextEditingController();
  final _teCountryCode = TextEditingController();
  final _tePassword = TextEditingController();

  FocusNode _focusNodeMobileEmail = new FocusNode();
  FocusNode _focusNodeCountryCode = new FocusNode();
  FocusNode _focusNodePassword = new FocusNode();

  FirebasePhoneUtil firebasePhoneUtil;
  FirebaseGoogleUtil firebaseGoogleUtil;
  FirebaseAnonymouslyUtil firebaseAnonymouslyUtil;

  @override
  void initState() {
    super.initState();
    _teCountryCode.text = '+1';
    firebasePhoneUtil = FirebasePhoneUtil();
    firebasePhoneUtil.setScreenListener(this);

    firebaseGoogleUtil = FirebaseGoogleUtil();
    firebaseGoogleUtil.setScreenListener(this);

    firebaseAnonymouslyUtil = FirebaseAnonymouslyUtil();
    firebaseAnonymouslyUtil.setScreenListener(this);
  }

  void _submit() {
    {
      setState(() {
        if (_isPhoneAuthEnable) {
          if (_teMobileEmail.text.isEmpty) {
            showAlert("Enter valid mobile number");
          } else {
            _isLoading = true;
            firebasePhoneUtil.verifyPhoneNumber(
                _teMobileEmail.text.trim(), _teCountryCode.text.trim());
            _isLoading = false;
          }
        } else if (_isEmailAuthEnable &&
            validateEmail(_teMobileEmail.text) == null) {
          _isLoading = true;
          login(_teMobileEmail.text, _tePassword.text);
        }
      });
    }
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      AppUtil().showAlert("Email is Required");
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      AppUtil().showAlert("Invalid Email");
      return "Invalid Email";
    } else {
      return null;
    }
  }

  void moveUserDashboardScreen(FirebaseUser currentUser) {
    eMailTabEnable();
    closeLoader();
    globals.currentFirebaseUser = currentUser;
    //Navigator.pushNamed(context, '/registration');
    if (globals.currentFirebaseUser.phoneNumber != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RegistrationTypeScreen(),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AuthScreen(),
      ));
    }

    // Navigator.of(context).push<String>(
    //   new MaterialPageRoute(
    //     settings: RouteSettings(name: '/home_screen'),
    //     builder: (context) => UserDashboardScreen(currentUser),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    new FirebaseNotifications().setUpFirebase();
    var tabs = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new GestureDetector(
          onTap: () {
            phoneTabEnable();
          },
          child: Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                size: 30,
                color: Colors.tealAccent,
              ),
              Text(
                'Phone',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        new SizedBox(
          width: 20.0,
        ),
        new SizedBox(
          width: 20.0,
        ),
        new GestureDetector(
          onTap: () {
            eMailTabEnable();
          },
          child: Row(
            children: <Widget>[
              Icon(
                Icons.alternate_email,
                size: 30,
                color: Colors.cyanAccent,
              ),
              Text(
                'Email/Password',
                style: TextStyle(color: Colors.cyan[50]),
              )
            ],
          ),
        ),
      ],
    );

    var phoneAuthForm = new Column(
      children: <Widget>[
        // FormBuilder(
        //   context,
        //   key: _fbKey,
        //   autovalidate: autoValidate,
        //   readonly: readOnly,
        //   /*onChanged: (formValue) {
        //             print(formValue);
        //           },*/
        //   controls: [
        //     FormBuilderInput.textField(
        //       type: FormBuilderInput.TYPE_PHONE,
        //       attribute: "phone",
        //       decoration: InputDecoration(labelText: "Phone Number"),
        //       //require: true,
        //     ),
        //   ],
        // ),

        new Row(
          children: <Widget>[
            new Expanded(
              child: new TextFormField(
                controller: _teCountryCode,
                focusNode: _focusNodeCountryCode,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.cyanAccent,
                  ),
                  labelText: "+1",
                  hintText: "+1",
                  hintStyle: TextStyle(color: Colors.cyan),
                  fillColor: new Color(0xFF2CB044),
                ),
              ),
              flex: 1,
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Expanded(
              child: new TextFormField(
                controller: _teMobileEmail,
                focusNode: _focusNodeMobileEmail,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.cyanAccent,
                  ),
                  hintText: "Mobile number",
                  hintStyle: TextStyle(color: Colors.cyan),
                  fillColor: new Color(0xFF2CB044),
                  prefixIcon: new Icon(
                    Icons.mobile_screen_share,
                    color: Colors.tealAccent,
                  ),
                ),
              ),
              flex: 5,
            ),
          ],
        ),
        new SizedBox(
          height: 40.0,
        ),
      ],
    );

    var anonymouslyForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _isEmailAuthEnable
            ? new SizedBox(
                height: 20.0,
              )
            : new SizedBox(
                height: 0.0,
              ),
        new TextFormField(
          controller: _teMobileEmail,
          focusNode: _focusNodeMobileEmail,
          style: new TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            labelStyle: const TextStyle(
              color: Colors.cyanAccent,
            ),
            hintText: "Email",
            hintStyle: TextStyle(color: Colors.cyan),
            fillColor: new Color(0xFF2CB044),
            prefixIcon: new Icon(
              Icons.email,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        new SizedBox(
          height: 10.0,
        ),
        new TextFormField(
          controller: _tePassword,
          focusNode: _focusNodePassword,
          style: new TextStyle(color: Colors.white),
          obscureText: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            labelStyle: const TextStyle(
              color: Colors.cyanAccent,
            ),
            hintText: "Password",
            hintStyle: TextStyle(color: Colors.cyan),
            fillColor: new Color(0xFF2CB044),
            prefixIcon: new Icon(
              Icons.account_box,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        new SizedBox(
          height: 30.0,
        ),
      ],
    );

    var googleForm = new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new SizedBox(
          height: 20.0,
        ),
        new Center(
          child: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        new SizedBox(
          height: 40.0,
        ),
      ],
    );

    var screenRoot =
        //new Container(
        // height: double.maxFinite,
        // alignment: FractionalOffset.center,
        // child: new SingleChildScrollView(
        //   child: new Center(
        //     child: loginForm,
        //   ),
        // ),
        new Column(
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        new Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: new Icon(CustomIcons.MedicallApp.logo_m,
                              size: 45.0,
                              color: Color.fromRGBO(255, 255, 255, 0.6)),
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
                //tabs,
                _isPhoneAuthEnable
                    ? phoneAuthForm
                    : _isEmailAuthEnable ? anonymouslyForm : anonymouslyForm,
                Column(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: () {
                        _submit();
                      },
                      child: new Container(
                        padding: EdgeInsets.all(10.0),
                        alignment: FractionalOffset.center,
                        width: 220,
                        decoration: new BoxDecoration(
                          color: Colors.tealAccent,
                          borderRadius:
                              new BorderRadius.all(const Radius.circular(3.0)),
                        ),
                        child: Text(
                          _isEmailAuthEnable
                              ? "LOGIN"
                              : _isPhoneAuthEnable ? "LOGIN" : "SUBMIT",
                          style: new TextStyle(
                              color: Colors.teal,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    _isEmailAuthEnable
                        ? new GestureDetector(
                            onTap: () {
                              _signUp();
                            },
                            child: new Container(
                              margin: EdgeInsets.only(top: 5.0),
                              padding: EdgeInsets.all(10.0),
                              width: 220,
                              alignment: FractionalOffset.center,
                              decoration: new BoxDecoration(
                                color: Colors.teal,
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(3.0)),
                              ),
                              child: Text(
                                "REGISTER",
                                style: new TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    GoogleSignInButton(
                        onPressed: () {
                          gMailTabEnable();
                        },
                        darkMode: false),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );

    return new Scaffold(
      appBar: null,
      key: _scaffoldKey,
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
          child: ProgressHUD(
            child: screenRoot,
            inAsyncCall: _isLoading,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.indigo),
            opacity: 0.0,
          ),
        ),
      ),
    );
  }

  @override
  verificationCodeSent(int forceResendingToken) {
    moveOtpVerificationScreen();
  }

  @override
  onLoginUserVerified(FirebaseUser currentUser) {
    moveUserDashboardScreen(currentUser);
  }

  @override
  onError(String msg) {
    showAlert(msg);
    setState(() {
      _isLoading = false;
    });
  }

  void phoneTabEnable() {
    setState(() {
      _isPhoneAuthEnable = true;
      _isEmailAuthEnable = false;
      _isGoogleAuthEnable = false;
      _teMobileEmail.text = "";
    });
  }

  void gMailTabEnable() {
    setState(() {
      _isPhoneAuthEnable = false;
      _isEmailAuthEnable = false;
      _isGoogleAuthEnable = true;
      _teMobileEmail.text = "";
      firebaseGoogleUtil.signInWithGoogle();
    });
  }

  void eMailTabEnable() {
    setState(() {
      _teMobileEmail.text = "";
      _isPhoneAuthEnable = false;
      _isEmailAuthEnable = true;
      _isGoogleAuthEnable = false;
    });
  }

  loginError(e) {
    setState(() {
      AppUtil().showAlert(e.message);
      _isLoading = false;
    });
  }

  void moveOtpVerificationScreen() {
    closeLoader();
    Navigator.pushNamed(context, '/verification');
  }

  void _signUp() {
    setState(() {
      if (_isEmailAuthEnable && validateEmail(_teMobileEmail.text) == null) {
        _isLoading = true;
        firebaseAnonymouslyUtil
            .createUser(_teMobileEmail.text, _tePassword.text)
            .then((String user) => login(_teMobileEmail.text, _tePassword.text))
            .catchError((e) => loginError(e));
      }
    });
  }

  login(String email, String pass) {
    firebaseAnonymouslyUtil
        .signIn(_teMobileEmail.text, _tePassword.text)
        .then((FirebaseUser user) => moveUserDashboardScreen(user))
        .catchError((e) => loginError(e));
  }

  void onLoginError(String errorTxt) {
    setState(() => _isLoading = false);
  }

  void closeLoader() {
    setState(() => _isLoading = false);
  }

  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlert(msg);
    });
  }

  void showLoader() {
    setState(() => _isLoading = true);
  }
}
