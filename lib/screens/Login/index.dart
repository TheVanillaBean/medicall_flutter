import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Login/sign_in_state_model.dart';
import 'package:Medicall/services/animation_provider.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final SignInStateModel model;

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context);
    final MyAnimationProvider animationProvider =
        Provider.of<MyAnimationProvider>(context);
    return ChangeNotifierProvider<SignInStateModel>(
      create: (context) => SignInStateModel(
        auth: auth,
        tempUserProvider: tempUserProvider,
        animationProvider: animationProvider,
      ),
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
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await model.signInWithGooglePressed(context);
      if (model.googleAuthModel != null) {
        model.tempUserProvider.updateWith(
          email: model.googleAuthModel.email,
          displayName: model.googleAuthModel.displayName,
          googleAuthModel: model.googleAuthModel,
        );
        _navigateToRegistrationScreen(context);
      }
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  void _navigateToRegistrationScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/registrationType');
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: ScreenUtil.screenHeight,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: model.animationProvider.returnAnimation(
                        tween: model.animationProvider.returnMultiTrackTween([
                          Colors.blueAccent.withAlpha(100),
                          Colors.cyanAccent.withAlpha(20),
                          Colors.cyanAccent.withAlpha(20),
                          Colors.blueAccent.withAlpha(100)
                        ]),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        radius: BorderRadius.all(Radius.circular(0)))),
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
    return [
      FadeIn(
        2,
        Padding(
            padding: const EdgeInsets.fromLTRB(60, 15, 60, 15),
            child: Column(
              children: <Widget>[
                _buildHeader(context),
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
                          model.tempUserProvider
                              .setMedicallUser(MedicallUser());
                          model.tempUserProvider.setGoogleAuthModel(null);
                          _navigateToRegistrationScreen(context);
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

  Widget _buildHeader(BuildContext context) {
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
                  color: Theme.of(context).primaryColor)),
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
                  color: Theme.of(context).colorScheme.secondary)),
        )
      ],
    );
  }

  Container _buildEmailAuthForm(BuildContext context) {
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
}
