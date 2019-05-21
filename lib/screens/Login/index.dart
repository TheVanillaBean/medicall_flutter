import 'package:Medicall/models/medicall_user.dart';
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
import 'package:Medicall/screens/Registration/RegistrationType/index.dart';
import 'package:Medicall/screens/Auth/index.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:Medicall/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  final MedicallUser medicallUser;

  const LoginPage({Key key, this.medicallUser}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage>
    implements FirebaseAuthListener {
  bool _isPhoneAuthEnable = false;
  bool _isGoogleAuthEnable = false;
  bool _isEmailAuthEnable = true;
  bool _isLoading = false;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  //GlobalKey<FormBuilderState> _fbKey = GlobalKey();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _teMobileEmail = TextEditingController();
  final _teCountryCode = TextEditingController();
  final _tePassword = TextEditingController();

  FocusNode _focusNodeMobileEmail = FocusNode();
  FocusNode _focusNodeCountryCode = FocusNode();
  FocusNode _focusNodePassword = FocusNode();

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

  Future<void> _getUserType(String id) async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + id);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data['type'] != null) {
        medicallUser.type = datasnapshot.data['type'];
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getTerms(String id) async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + id);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data['terms'] != null) {
        medicallUser.terms = true;
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getPolicy(String id) async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + id);
    await documentReference.get().then((datasnapshot) {
      if (datasnapshot.data['policy'] != null) {
        medicallUser.terms = true;
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
    globals.currentFirebaseUser = currentUser;
    
    medicallUser = MedicallUser(id: currentUser.uid);
    await _getUserType(currentUser.uid);
    await _getTerms(currentUser.uid);
    await _getPolicy(currentUser.uid);
    //medicallUser = MedicallUser(id: currentUser.uid);
    //Navigator.pushNamed(context, '/registration');

    //TO-DO delete more hacks to bypass terms/ registration for development
    //medicallUser.terms = true;
    //medicallUser.policy = true;

    if (currentUser.isEmailVerified == true &&
        currentUser.phoneNumber != null) {
      if (medicallUser.terms == true && medicallUser.policy == true) {
        Navigator.pushNamed(context, '/doctors');
      } else {
        if (medicallUser.type == 'patient') {
          Navigator.pushNamed(context, '/registrationPatient');
        }
        if (medicallUser.type == 'provider') {
          Navigator.pushNamed(context, '/registrationProvider');
        }
        if (medicallUser.type == null) {
          Navigator.pushNamed(context, '/registrationType');
        }
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AuthScreen(),
      ));
    }

    // Navigator.of(context).push<String>(
    //    MaterialPageRoute(
    //     settings: RouteSettings(name: '/home_screen'),
    //     builder: (context) => UserDashboardScreen(currentUser),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseNotifications().setUpFirebase();
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
        SizedBox(
          width: 20.0,
        ),
        SizedBox(
          width: 20.0,
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
            SizedBox(
              width: 10.0,
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
        SizedBox(
          height: 40.0,
        ),
      ],
    );

    var anonymouslyForm = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _isEmailAuthEnable
            ? SizedBox(
                height: 20.0,
              )
            : SizedBox(
                height: 0.0,
              ),
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
          height: 10.0,
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
              Icons.verified_user,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );

    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: 20.0,
        ),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        SizedBox(
          height: 40.0,
        ),
      ],
    );

    var screenRoot = Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                Column(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 225.0,
                      height: 50.0,
                      child: RaisedButton(
                        color: Theme.of(context).colorScheme.primaryVariant,
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
                    SizedBox(
                      height: 10,
                    ),
                    ButtonTheme(
                      minWidth: 225.0,
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
                    SizedBox(
                      height: 5,
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

    return Scaffold(
      appBar: null,
      key: _scaffoldKey,
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
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
