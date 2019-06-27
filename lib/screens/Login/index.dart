import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Login/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_google_util.dart';
import 'package:Medicall/util/firebase_listenter.dart';
import 'package:Medicall/util/firebase_phone_util.dart';
import 'package:Medicall/components/progress_hud.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:Medicall/screens/Auth/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flutter/cupertino.dart';

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
      return (prefs.getString('requestedRoute'));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getUser() async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + firebaseUser.uid);
    await documentReference.get().then((datasnapshot) {
      //FirebaseNotifications().setUpFirebase(_tokens, context);
      // String currDevToken = _tokens.currentDevToken;
      // List<dynamic> dbDevTokens = datasnapshot.data['dev_tokens'];
      // List<String> finalDevTokenList = [
      //   currDevToken,
      // ];
      // if (!finalDevTokenList.contains(currDevToken) &&
      //     currDevToken != null &&
      //     currDevToken != '') {
      //   finalDevTokenList.add(currDevToken);
      // }
      if (datasnapshot.data != null) {
        medicallUser.id = firebaseUser.uid;
        medicallUser.displayName = datasnapshot.data['name'];
        medicallUser.firstName = datasnapshot.data['first_name'];
        medicallUser.lastName = datasnapshot.data['last_name'];
        medicallUser.dob = datasnapshot.data['dob'];
        medicallUser.policy = datasnapshot.data['policy'];
        medicallUser.terms = datasnapshot.data['terms'];
        medicallUser.type = datasnapshot.data['type'];
        medicallUser.email = datasnapshot.data['email'];
        medicallUser.phoneNumber = datasnapshot.data['phone'];
      } else {
        medicallUser.id = medicallUser.displayName = firebaseUser.displayName;
        medicallUser.firstName = firebaseUser.displayName.split(' ')[0];
        medicallUser.lastName = firebaseUser.displayName.split(' ')[1];
        medicallUser.policy = false;
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
          "terms": false,
          "type": null,
        };
        documentReference.updateData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));
      }
      if (datasnapshot.data['dev_tokens'] == null ||
          datasnapshot.data['dev_tokens'][0] != medicallUser.devTokens[0]) {
        Map<String, dynamic> data = <String, dynamic>{
          "dev_tokens": medicallUser.devTokens,
        };
        documentReference.updateData(data).whenComplete(() {
          print("Document Added");
        }).catchError((e) => print(e));
      }
    }).catchError((e) => print(e));
  }

  void _submit() {
    {
      setState(() {
        //FirebaseNotifications().setUpFirebase(_tokens, context);
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
    RegExp regExp = RegExp(pattern);
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

  Future moveUserDashboardScreen(FirebaseUser currentUser) async {
    eMailTabEnable();
    closeLoader();
    firebaseUser = currentUser;
    await _getUser();
    final SharedPreferences prefs = await _prefs;
    await _requestedRoute.then((onValue) {
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
      if (currentUser.isEmailVerified == true &&
          currentUser.phoneNumber != null) {
        //print(widget.requestedRoute.toString());

        if (medicallUser.terms == true && medicallUser.policy == true) {
          if (medicallUser.type == 'provider') {
            Navigator.pushNamed(context, '/history',
                arguments: {'user': medicallUser});
          } else {
            Navigator.pushNamed(context, '/doctors',
                arguments: {'user': medicallUser});
          }
        } else {
          if (medicallUser.type == null) {
            Navigator.pushNamed(context, '/registrationType',
                arguments: {'user': medicallUser});
          } else {
            Navigator.pushNamed(context, '/registration',
                arguments: {'user': medicallUser});
          }
        }
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ));
      }
    });
    //showToast(_requestedRoute.toString(), duration: Duration(minutes: 1));
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

    var anonymouslyForm = Column(
      children: <Widget>[
        // FutureBuilder<String>(
        //     future: _requestedRoute,
        //     builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        //       switch (snapshot.connectionState) {
        //         case ConnectionState.waiting:
        //           return const CircularProgressIndicator();
        //         default:
        //           if (snapshot.hasError)
        //             return Text('Error: ${snapshot.error}');
        //           else
        //             return Text('${snapshot.data}\n\n');
        //       }
        //     }),
        TextFormField(
          controller: _teMobileEmail,
          focusNode: _focusNodeMobileEmail,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
            hintText: "Email",
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondaryVariant),
            prefixIcon: Icon(
              Icons.email,
              color: Theme.of(context).colorScheme.background,
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
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondaryVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
            hintText: "Password",
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondaryVariant),
            prefixIcon: Icon(
              Icons.lock,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: ExactAssetImage(
                                    'assets/icon/logo_back.png'),
                              )),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            'assets/icon/logo_fore.png',
                          ),
                        ),
                      ],
                    ),
                    Text('Medicall',
                        style: TextStyle(
                            fontSize: 26.0,
                            height: 1.08,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary)),
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryVariant,
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                onPressed: () {
                                  _signUp();
                                },
                                child: Text(
                                  "Register",
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
                            child: GoogleSignInButton(
                              text: "Google Sign In",
                                onPressed: () {
                                  gMailTabEnable();
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
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          image: backgroundImage,
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
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
