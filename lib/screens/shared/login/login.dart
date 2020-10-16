import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Shared/Login/sign_in_state_model.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart' as AppleSignInButton;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
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
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await model.signInWithGooglePressed(context);
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      await model.signInWithApplePressed(context);
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  void _navigateToResetPasswordScreen(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.reset_password);
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
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "",
        theme: Theme.of(context),
      ),
      body: KeyboardDismisser(
        gestures: [GestureType.onTap, GestureType.onVerticalDragDown],
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          sized: false,
          child: SingleChildScrollView(
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
            padding: const EdgeInsets.fromLTRB(45, 15, 45, 15),
            child: Column(
              children: <Widget>[
                _buildHeader(context),
                SizedBox(height: height * 0.09),
                _buildEmailAuthForm(context),
                SizedBox(height: height * 0.01),
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
                Text("-or-"),
                SizedBox(height: 24),
                SocialSignInButton(
                  context: context,
                  imgPath: "assets/images/google-logo.png",
                  text: "Sign in with Google",
                  color: Colors.white,
                  textColor: Colors.black87,
                  onPressed:
                      model.isLoading ? null : () => _signInWithGoogle(context),
                ),
                SizedBox(height: height * 0.01),
                if (appleSignInAvailable.isAvailable) SizedBox(height: 12),
                if (appleSignInAvailable.isAvailable)
                  SizedBox(
                    height: 40,
                    child: AppleSignInButton.AppleSignInButton(
                      style: AppleSignInButton.ButtonStyle.whiteOutline,

                      type: AppleSignInButton
                          .ButtonType.signIn, // style as needed
                      onPressed: model.isLoading
                          ? null
                          : () => _signInWithApple(context),
                    ),
                  ),
                SizedBox(height: height * 0.02),
                ReusableRaisedButton(
                    title: "Reset Password",
                    outlined: true,
                    color: Theme.of(context).disabledColor.withAlpha(80),
                    onPressed: () => _navigateToResetPasswordScreen(context)),
                SizedBox(height: height * 0.01),
              ],
            )),
      ),
    ];
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 160,
          height: 120,
          child: Image.asset(
            'assets/icon/letter_mark.png',
          ),
        ),
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
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withAlpha(20),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
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
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.grey.withAlpha(20),
        prefixIcon: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
        ),
        labelText: 'Email',
        hintText: 'john@doe.com',
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }
}
