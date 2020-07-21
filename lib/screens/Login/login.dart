import 'dart:ui' as ui;

import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Login/sign_in_state_model.dart';
import 'package:Medicall/screens/Welcome/welcome.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final SignInStateModel model;

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return ChangeNotifierProvider<SignInStateModel>(
      create: (context) => SignInStateModel(
        auth: auth,
        tempUserProvider: tempUserProvider,
      ),
      child: Consumer<SignInStateModel>(
        builder: (_, model, __) => LoginScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.login);
  }

  LoginScreen({@required this.model});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  SignInStateModel get model => widget.model;

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
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await model.signInWithGooglePressed(context);
      if (model.googleAuthModel != null) {
        model.tempUserProvider.user.email = model.googleAuthModel.email;
        model.tempUserProvider.user.fullName = model.googleAuthModel.fullName;
        model.tempUserProvider.googleAuthModel = model.googleAuthModel;

        _navigateToRegistrationScreen(context);
      }
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      await model.signInWithApplePressed(context);
      if (model.appleSignInModel != null) {
        model.tempUserProvider.user.email = model.appleSignInModel.email;
        model.tempUserProvider.user.fullName = model.appleSignInModel.fullName;
        model.tempUserProvider.appleSignInModel = model.appleSignInModel;
        _navigateToRegistrationScreen(context);
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  void _navigateToRegistrationScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/registrationType');
  }

  void _navigateToResetPasswordScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/reset_password');
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: MediaQueryData.fromWindow(ui.window).size.height * 1.1,
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  child: SafeArea(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Stack(
                        children: _buildChildren(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    final height = MediaQuery.of(context).size.height;
    return [
      FadeIn(
        2,
        Padding(
            padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
            child: Column(
              children: <Widget>[
                _buildHeader(context),
                SizedBox(height: height * 0.09),
                _buildEmailAuthForm(context),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SignInButton(
                        color: Theme.of(context).colorScheme.primary,
                        textColor: Colors.white,
                        text: "Sign in",
                        onPressed: model.canSubmit ? _submit : null,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 24),
                SocialSignInButton(
                  imgPath: "assets/images/google-logo.png",
                  text: "Sign in with Google",
                  color: Colors.white,
                  textColor: Colors.black87,
                  onPressed:
                      model.isLoading ? null : () => _signInWithGoogle(context),
                ),
                SizedBox(height: 12),
                if (appleSignInAvailable.isAvailable) SizedBox(height: 12),
                if (appleSignInAvailable.isAvailable)
                  AppleSignInButton(
                    style: ButtonStyle.black, // style as needed
                    type: ButtonType.signIn, // style as needed
                    onPressed: model.isLoading
                        ? null
                        : () => _signInWithApple(context),
                  ),
                SizedBox(height: 24),
                OutlineButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Text(
                    "Reset Password",
                    style: TextStyle(color: Colors.black54),
                  ),
                  onPressed: () => _navigateToResetPasswordScreen(context),
                ),
                SizedBox(height: 5),
                OutlineButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Text(
                    "First time here?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  onPressed: () => WelcomeScreen.show(context: context),
                ),
              ],
            )),
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
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
                  color: Theme.of(context).colorScheme.primary)),
        ),
        SizedBox(
          width: width * 0.25,
          height: height * 0.15,
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
      child: Column(
        children: <Widget>[
          Container(
            height: 90,
            child: _buildEmailTextField(),
          ),
          Container(
            height: 90,
            child: _buildPasswordTextField(),
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
        filled: true,
        fillColor: Colors.white.withAlpha(100),
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
        filled: true,
        fillColor: Colors.white.withAlpha(100),
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
}
