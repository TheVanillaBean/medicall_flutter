import 'package:Medicall/components/progress_hud.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Auth/index.dart';
import 'package:Medicall/screens/Registration/RegistrationType/index.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_auth_codes.dart';
import 'package:Medicall/util/firebase_google_util.dart';
import 'package:Medicall/util/firebase_listenter.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:Medicall/util/firebase_phone_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage>
    implements FirebaseAuthListener {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool _isPhoneAuthEnable = false;
  bool _isEmailAuthEnable = true;
  bool _isLoading = false;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;

  final _teMobileEmail = TextEditingController();
  final _teCountryCode = TextEditingController();
  final _tePassword = TextEditingController();

  FocusNode _focusNodeMobileEmail = FocusNode();
  FocusNode _focusNodeCountryCode = FocusNode();
  FocusNode _focusNodePassword = FocusNode();

  FirebasePhoneUtil firebasePhoneUtil;
  FirebaseGoogleUtil firebaseGoogleUtil;
  FirebaseAnonymouslyUtil firebaseAnonymouslyUtil;
  FirebaseUser firebaseUser;
  Future<String> _requestedRoute;

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

    FirebaseNotifications().setUpFirebase();

    _requestedRoute = _prefs.then((SharedPreferences prefs) {
      if (prefs.containsKey('requestedRoute') &&
          prefs.getString('requestedRoute').length > 0) {
        return (prefs.getString('requestedRoute'));
      } else {
        return null;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tePassword.clear();
  }

  Future<void> _getUser() async {
    final DocumentReference documentReference =
        Firestore.instance.collection("users").document(firebaseUser.uid);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data != null) {
        medicallUser.id = firebaseUser.uid;
        medicallUser.displayName = datasnapshot.data['name'];
        medicallUser.firstName = datasnapshot.data['first_name'];
        medicallUser.lastName = datasnapshot.data['last_name'];
        medicallUser.dob = datasnapshot.data['dob'];
        medicallUser.policy = datasnapshot.data['policy'];
        medicallUser.consent = datasnapshot.data['consent'];
        medicallUser.terms = datasnapshot.data['terms'];
        medicallUser.type = datasnapshot.data['type'];
        medicallUser.email = datasnapshot.data['email'];
        medicallUser.phoneNumber = datasnapshot.data['phone'];
      } else {
        if (firebaseUser.displayName != null) {
          medicallUser.displayName = firebaseUser.displayName;
          medicallUser.firstName = firebaseUser.displayName.split(' ')[0];
          medicallUser.lastName = firebaseUser.displayName.split(' ')[1];
        }
        medicallUser.id = firebaseUser.uid;
        medicallUser.policy = false;
        medicallUser.consent = false;
        medicallUser.terms = false;
        medicallUser.email = firebaseUser.email;
        medicallUser.phoneNumber = firebaseUser.phoneNumber;
        Map<String, dynamic> data = <String, dynamic>{
          "name": firebaseUser.displayName,
          "first_name": firebaseUser.displayName.split(' ')[0],
          "last_name": firebaseUser.displayName.split(' ')[1],
          "email": firebaseUser.email,
          "phone": firebaseUser.phoneNumber,
          "dob": null,
          "policy": false,
          "consent": false,
          "terms": false,
          "type": null,
          "dev_tokens": medicallUser.devTokens,
        };
        documentReference.setData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));
      }
    }).catchError((e) => print(e));
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
            validateEmail(_teMobileEmail.text, 'signin') == null) {
          _isLoading = true;
          login(_teMobileEmail.text, _tePassword.text);
        }
      });
    }
  }

  String validateEmail(String value, String from) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      if (from == 'signup') {
        AppUtil().showAlert(
            "If you are new to Medicall enter your email and desired password below, tap 'Create New Account', and we will take you to registration.",
            7);
      } else {
        AppUtil().showAlert("Enter your email and password.", 7);
      }
      return "Please provide your email and enter a password.";
    } else if (!regExp.hasMatch(value)) {
      AppUtil().showAlert("Invalid Email", 10);
      return "Invalid Email";
    } else {
      return null;
    }
  }

  Future moveUserDashboardScreen(FirebaseUser currentUser) async {
    eMailTabEnable();
    closeLoader();
    if (currentUser == null) {
      Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => RegistrationTypeScreen(
          data: {"user": medicallUser},
        ),
      ));
    } else {
      firebaseUser = currentUser;
      await _getUser();
      final SharedPreferences prefs = await _prefs;
      await _requestedRoute.then((onValue) {
        _tePassword.clear();
        if (onValue != null && onValue != "") {
          String newValue = onValue
              .replaceAll("[", "")
              .replaceAll("]", "")
              .replaceAll(RegExp(r"/\s/g"), "")
              .trim();
          List<String> finalValue = newValue.split(",");
          finalValue[1] = finalValue[1].trim();
          Navigator.pushReplacementNamed(context, '/' + finalValue[0],
              arguments: {
                'user': medicallUser,
                'documentId': finalValue[1],
                'isRouted': true,
              });
          prefs.setString("requestedRoute", "").then((bool success) {
            print('shared pref success');
          });
          return;
        }
        if (currentUser.phoneNumber != null) {
          Navigator.pushReplacementNamed(context, '/history',
              arguments: {'user': medicallUser});
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AuthScreen(),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            phoneTabEnable();
          },
          child: Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
              Text(
                'Phone',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            eMailTabEnable();
          },
          child: Row(
            children: <Widget>[
              Icon(
                Icons.alternate_email,
                size: 30,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              Text(
                'Email/Password',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryVariant),
              )
            ],
          ),
        ),
      ],
    );

    var phoneAuthForm = Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _teCountryCode,
                focusNode: _focusNodeCountryCode,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  labelText: "+1",
                  hintText: "+1",
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondaryVariant),
                ),
              ),
              flex: 1,
            ),
            Expanded(
              child: TextFormField(
                controller: _teMobileEmail,
                focusNode: _focusNodeMobileEmail,
                keyboardType: TextInputType.number,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondaryVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  hintText: "Mobile number",
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondaryVariant),
                  prefixIcon: Icon(
                    Icons.mobile_screen_share,
                    color: Theme.of(context).colorScheme.secondaryVariant,
                  ),
                ),
              ),
              flex: 5,
            ),
          ],
        ),
      ],
    );

    var anonymouslyForm = Flex(
      direction: Axis.vertical,
      children: <Widget>[
        TextFormField(
          controller: _teMobileEmail,
          focusNode: _focusNodeMobileEmail,
          style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(150)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(150)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
            hintText: "Email",
            hintStyle: TextStyle(color: Color.fromRGBO(100, 100, 100, 1)),
            prefixIcon: Icon(
              Icons.email,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        TextFormField(
          controller: _tePassword,
          focusNode: _focusNodePassword,
          obscureText: true,
          style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(150)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(150)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            hintText: "Password",
            hintStyle: TextStyle(color: Color.fromRGBO(100, 100, 100, 1)),
            prefixIcon: Icon(
              Icons.lock,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
      ],
    );

    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );

    var screenRoot = Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(70, 0, 60, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      transform: Matrix4.translationValues(12.0, 0.0, 0.0),
                      child: Text('MEDI',
                          style: TextStyle(
                              fontSize: 26.0,
                              height: 1.08,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.secondary)),
                    ),
                    Container(
                      width: 110,
                      height: 110,
                      child: Image.asset(
                        'assets/icon/logo_fore.png',
                      ),
                    ),
                    Container(
                      transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
                      child: Text('CALL',
                          style: TextStyle(
                              fontSize: 26.0,
                              height: 1.08,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary)),
                    )
                  ],
                ),
                //tabs,
                _isPhoneAuthEnable
                    ? phoneAuthForm
                    : _isEmailAuthEnable ? anonymouslyForm : anonymouslyForm,
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ButtonTheme(
                              height: 50.0,
                              child: RaisedButton(
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  _submit();
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(letterSpacing: 1.3),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ButtonTheme(
                              height: 50.0,
                              child: RaisedButton(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryVariant
                                    .withBlue(3000),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                onPressed: () {
                                  _signUp();
                                  _tePassword.clear();
                                },
                                child: Text(
                                  "Create New Account",
                                  style: TextStyle(letterSpacing: 1.3),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: GoogleSignInButton(
                                text: "Google Sign In",
                                onPressed: () {
                                  gMailTabEnable();
                                  _tePassword.clear();
                                  Future.delayed(
                                      const Duration(milliseconds: 1000), () {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });
                                },
                                darkMode: false),
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: null,
      body: Container(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: <Color>[
              const Color.fromRGBO(220, 255, 255, 0.9),
              const Color.fromRGBO(88, 178, 214, 0.8),
            ],
            stops: [0.1, 1],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
          )),
          child: ProgressHUD(
            child: screenRoot,
            inAsyncCall: _isLoading,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    setState(() {
      _isLoading = false;
    });
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
      _teMobileEmail.text = "";
    });
  }

  void gMailTabEnable() {
    setState(() {
      _isLoading = true;
      _isPhoneAuthEnable = false;
      _isEmailAuthEnable = false;
      _teMobileEmail.text = "";
      firebaseGoogleUtil.signInWithGoogle();
    });
  }

  void eMailTabEnable() {
    setState(() {
      _teMobileEmail.text = "";
      _isPhoneAuthEnable = false;
      _isEmailAuthEnable = true;
    });
  }

  loginError(e) {
    setState(() {
      AppUtil().showAlert(e, 10);
      _tePassword.clear();
      _isLoading = false;
    });
  }

  void moveOtpVerificationScreen() {
    closeLoader();
    Navigator.pushNamed(context, '/verification');
  }

  void _signUp() {
    setState(() {
      _isLoading = true;
      FirebaseUser user;
      moveUserDashboardScreen(user);
    });
  }

  login(String email, String pass) {
    firebaseAnonymouslyUtil
        .signIn(email, pass)
        .then((FirebaseUser user) => moveUserDashboardScreen(user))
        .catchError((e) => e.code == 'ERROR_USER_NOT_FOUND'
            ? _signUp()
            : loginError(getErrorMessage(error: e)));
  }

  String getErrorMessage({dynamic error}) {
    if (error.code == FirebaseAuthCodes.ERROR_USER_NOT_FOUND) {
      return "A user with this email does not exist. Register first.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_DISABLED) {
      return "This user account has been disabled.";
    } else if (error.code == FirebaseAuthCodes.ERROR_USER_TOKEN_EXPIRED) {
      return "A password change is in the process.";
    } else {
      return error.message;
    }
  }

  void onLoginError(String errorTxt) {
    setState(() => _isLoading = false);
  }

  void closeLoader() {
    setState(() => _isLoading = false);
  }

  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlert(msg, 10);
    });
  }

  void showLoader() {
    setState(() => _isLoading = true);
  }
}
