import 'dart:ui' as ui;
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/screens/Login/sign_in_state_model.dart';
import 'package:Medicall/screens/Registration/registrationType.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flare_flutter/flare_actor.dart';
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
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await model.signInWithGoogle();
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  void _createAccountWithEmail(BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => RegistrationTypeScreen(),
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
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
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      Container(
        margin: EdgeInsets.only(top: 30),
        height: 100,
        child: FlareActor(
          'assets/headerlogo.flr',
          fit: BoxFit.fitWidth,
          snapToEnd: true,
          animation: 'Untitled',
        ),
      ),
      FadeIn(
        2,
        Padding(
            padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                _buildEmailAuthForm(context),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SignInButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        text: "Sign in",
                        onPressed: model.canSubmit ? _submit : _submit,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  "",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SignInButton(
                        color: Theme.of(context).primaryColor.withBlue(3000),
                        textColor: Colors.white,
                        text: "Create New Account",
                        onPressed: () {
                          _createAccountWithEmail(context);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8),
                SocialSignInButton(
                  imgPath: "assets/images/google-logo.png",
                  text: "Sign in with Google",
                  color: Colors.white,
                  textColor: Colors.black87,
                  onPressed:
                      model.isLoading ? null : () => _signInWithGoogle(context),
                ),
              ],
            )),
      ),
    ];
  }

  Container _buildEmailAuthForm(BuildContext context) {
    // if (model.isLoading) {
    //   return Container(
    //     height: 225,
    //     padding: const EdgeInsets.only(bottom: 16.0),
    //     child: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
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

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[
          const Color.fromRGBO(220, 255, 255, 0.5),
          const Color.fromRGBO(88, 178, 214, 0.8),
        ],
        stops: [0.1, 1],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(0.0, 1.0),
      ),
    );
  }
}
