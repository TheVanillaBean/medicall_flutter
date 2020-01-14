import 'dart:ui' as ui;

import 'package:Medicall/common_widgets/platform_exception_alert_dialog.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Login/sign_in_state_model.dart';
import 'package:Medicall/screens/Registration/RegistrationType/index.dart';
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
      //Navigator.of(context).pop();
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
      PlatformExceptionAlertDialog(
        title: 'Sign in failed',
        exception: e,
      ).show(context);
    }
  }

  void _createAccountWithEmail(BuildContext context) {
    GlobalNavigatorKey.key.currentState.push(CupertinoPageRoute(
      builder: (context) => RegistrationTypeScreen(
        data: {"user": medicallUser},
      ),
    ));
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

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
                    padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
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

  Container _buildEmailAuthForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
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
