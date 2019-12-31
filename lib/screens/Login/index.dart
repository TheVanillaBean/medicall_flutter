import 'dart:ui' as ui;

import 'package:Medicall/common_widgets/platform_exception_alert_dialog.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/screens/Login/sign_in_state_model.dart';
import 'package:Medicall/screens/Registration/index.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final SignInStateModel model;

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<SignInStateModel>(
      create: (context) => SignInStateModel(auth: auth),
      child: Consumer<SignInStateModel>(
        builder: (_, model, __) => LoginPage(
          model: model,
        ),
      ),
    );
  }

  LoginPage({@required this.model});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  static const REQUESTED_ROUTE = 'requestedRoute';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  SignInStateModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    FirebaseNotifications().setUpFirebase();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: 'Sign in failed',
        exception: e,
      ).show(context);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await model.signInWithGoogle();
    } on PlatformException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        PlatformExceptionAlertDialog(
          title: 'Sign in failed',
          exception: e,
        ).show(context);
      }
    }
  }

  void _createAccountWithEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => RegistrationScreen(data: null),
    ));
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

//  Future<void> _getUser() async {
//    final DocumentReference documentReference =
//        Firestore.instance.collection("users").document(firebaseUser.uid);
//    await documentReference.get().then((datasnapshot) {
//      if (datasnapshot.data != null) {
//        medicallUser.uid = firebaseUser.uid;
//        medicallUser.displayName = datasnapshot.data['name'];
//        medicallUser.firstName = datasnapshot.data['first_name'];
//        medicallUser.lastName = datasnapshot.data['last_name'];
//        medicallUser.dob = datasnapshot.data['dob'];
//        medicallUser.policy = datasnapshot.data['policy'];
//        medicallUser.consent = datasnapshot.data['consent'];
//        medicallUser.terms = datasnapshot.data['terms'];
//        medicallUser.type = datasnapshot.data['type'];
//        medicallUser.email = datasnapshot.data['email'];
//        medicallUser.phoneNumber = datasnapshot.data['phone'];
//      } else {
//        if (firebaseUser.displayName != null) {
//          medicallUser.displayName = firebaseUser.displayName;
//          medicallUser.firstName = firebaseUser.displayName.split(' ')[0];
//          medicallUser.lastName = firebaseUser.displayName.split(' ')[1];
//        }
//        medicallUser.uid = firebaseUser.uid;
//        medicallUser.policy = false;
//        medicallUser.consent = false;
//        medicallUser.terms = false;
//        medicallUser.email = firebaseUser.email;
//        medicallUser.phoneNumber = firebaseUser.phoneNumber;
//        Map<String, dynamic> data = <String, dynamic>{
//          "name": firebaseUser.displayName,
//          "first_name": firebaseUser.displayName.split(' ')[0],
//          "last_name": firebaseUser.displayName.split(' ')[1],
//          "email": firebaseUser.email,
//          "phone": firebaseUser.phoneNumber,
//          "dob": null,
//          "policy": false,
//          "consent": false,
//          "terms": false,
//          "type": null,
//          "dev_tokens": medicallUser.devTokens,
//        };
//        documentReference.setData(data).whenComplete(() {
//          print("Document Added");
//        }).catchError((e) => print(e));
//      }
//    }).catchError((e) => print(e));
//  }

//  Future moveUserDashboardScreen(FirebaseUser currentUser) async {
//    if (currentUser == null) {
//      Navigator.of(context).push(CupertinoPageRoute(
//        builder: (context) => RegistrationTypeScreen(
//          data: {"user": medicallUser},
//        ),
//      ));
//    } else {
//      firebaseUser = currentUser;
//      await _getUser();
//      final SharedPreferences prefs = await _prefs;
//      await _requestedRoute.then((onValue) {
//        _passwordController.clear();
//        if (onValue != null && onValue != "") {
//          String newValue = onValue
//              .replaceAll("[", "")
//              .replaceAll("]", "")
//              .replaceAll(RegExp(r"/\s/g"), "")
//              .trim();
//          List<String> finalValue = newValue.split(",");
//          finalValue[1] = finalValue[1].trim();
//          Navigator.pushReplacementNamed(context, '/' + finalValue[0],
//              arguments: {
//                'user': medicallUser,
//                'documentId': finalValue[1],
//                'isRouted': true,
//              });
//          prefs.setString("requestedRoute", "").then((bool success) {
//            print('shared pref success');
//          });
//          return;
//        }
//        if (currentUser.phoneNumber != null) {
//          Navigator.pushReplacementNamed(context, '/history',
//              arguments: {'user': medicallUser});
//        } else {
//          Navigator.of(context).push(MaterialPageRoute(
//            builder: (context) => AuthScreen(),
//          ));
//        }
//      });
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: MediaQueryData.fromWindow(ui.window).size.height,
            ),
            child: Container(
              decoration: _buildContainerDecoration(),
              child: SafeArea(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildChildren(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      _buildHeader(context),
      _buildEmailAuthForm(context),
      SizedBox(height: 16.0),
      SignInButton(
        color: Theme.of(context).colorScheme.primary,
        textColor: Colors.white,
        text: "Sign in",
        onPressed: model.canSubmit ? _submit : null,
      ),
      SizedBox(height: 12),
      Text(
        "or",
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 12),
      SignInButton(
        color: Theme.of(context).colorScheme.primaryVariant.withBlue(3000),
        textColor: Colors.white,
        text: "Create New Account",
        onPressed: () => _createAccountWithEmail(context),
      ),
      SizedBox(height: 8),
      SocialSignInButton(
        imgPath: "assets/images/google-logo.png",
        text: "Sign in with Google",
        color: Colors.white,
        textColor: Colors.black87,
        onPressed: model.isLoading ? null : () => _signInWithGoogle(context),
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    if (model.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Row(
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
        SizedBox(
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
    );
  }

  Card _buildEmailAuthForm(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildEmailTextField(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            _buildPasswordTextField(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }

  TextField _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      autocorrect: false,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onEditingComplete: _submit,
      onChanged: model.updatePassword,
      style: TextStyle(
        color: Color.fromRGBO(80, 80, 80, 1),
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        labelText: 'Password',
        errorText: model.passwordErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  TextField _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _emailEditingComplete,
      onChanged: model.updateEmail,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        prefixIcon: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        labelText: 'Email',
        hintText: 'john@doe.com',
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[
          const Color.fromRGBO(220, 255, 255, 0.9),
          const Color.fromRGBO(88, 178, 214, 0.8),
        ],
        stops: [0.1, 1],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(0.0, 1.0),
      ),
    );
  }
}
