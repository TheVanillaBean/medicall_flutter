import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/common_widgets/social_sign_in_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/registration_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:super_rich_text/super_rich_text.dart';

class RegistrationScreen extends StatefulWidget {
  final RegistrationViewModel model;

  const RegistrationScreen({@required this.model});

  static Widget create(BuildContext context) {
    final NonAuthDatabase db =
        Provider.of<NonAuthDatabase>(context, listen: false);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return ChangeNotifierProvider<RegistrationViewModel>(
      create: (context) => RegistrationViewModel(
        nonAuthDatabase: db,
        auth: auth,
        tempUserProvider: tempUserProvider,
      ),
      child: Consumer<RegistrationViewModel>(
        builder: (_, model, __) => RegistrationScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.registration);
  }

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with VerificationStatus {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  RegistrationViewModel get model => widget.model;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
    if (!model.checkValue) {
      _showFlushBarMessage(
          "You have to agree to the Terms and Conditions, as well as the Privacy Policy before signing in.");
      return;
    }

    try {
      await model.signInWithGooglePressed(context);
      if (model.googleAuthModel != null) {
        model.tempUserProvider.user.email = model.googleAuthModel.email;
        model.tempUserProvider.user.fullName = model.googleAuthModel.fullName;
        model.tempUserProvider.googleAuthModel = model.googleAuthModel;
      }
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    if (!model.checkValue) {
      _showFlushBarMessage(
          "You have to agree to the Terms and Conditions, as well as the Privacy policy before signing in");
      return;
    }

    try {
      await model.signInWithApplePressed(context);
      if (model.appleSignInModel != null) {
        if (model.googleAuthModel != null) {
          model.tempUserProvider.user.email = model.appleSignInModel.email;
          model.tempUserProvider.user.fullName =
              model.appleSignInModel.fullName;
          model.tempUserProvider.appleSignInModel = model.appleSignInModel;
        }
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    model.setVerificationStatus(this);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Protect your Information',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildChildren(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    model.setVerificationStatus(this);
    return <Widget>[
      Text(
        "Help us protect your personal information by choosing a secure log in. This is required to start your visit.",
      ),
      SizedBox(height: 24.0),
      _buildEmailAuthForm(context),
      SizedBox(height: 12.0),
      Row(
        children: <Widget>[
          Expanded(
            child: SignInButton(
              color: Theme.of(context).colorScheme.primary,
              textColor: Colors.white,
              text: "Sign Up",
              onPressed: model.canSubmit &&
                      model.googleAuthModel == null &&
                      model.appleSignInModel == null
                  ? _submit
                  : null,
            ),
          )
        ],
      ),
      SizedBox(height: 24),
      Text("-or-"),
      SizedBox(height: 24),
      SocialSignInButton(
        imgPath: "assets/images/google-logo.png",
        text: "Sign in with Google",
        color: Colors.white,
        textColor: Colors.black87,
        onPressed: model.isLoading ? null : () => _signInWithGoogle(context),
      ),
      SizedBox(height: 24),
      if (appleSignInAvailable.isAvailable) SizedBox(height: 12),
      if (appleSignInAvailable.isAvailable)
        AppleSignInButton(
          style: ButtonStyle.black, // style as needed
          type: ButtonType.signIn, // style as needed
          onPressed: model.isLoading ? null : () => _signInWithApple(context),
        ),
      SizedBox(height: 12.0),
    ];
  }

  Widget _buildEmailAuthForm(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 75,
          child: _buildEmailTextField(),
        ),
        Container(
          height: 75,
          child: _buildPasswordTextField(),
        ),
        Container(
          height: 75,
          child: _buildConfirmPasswordTextField(),
        ),
        Container(
          height: 75,
          child: _buildTermsCheckbox(),
        ),
      ],
    );
  }

  Widget _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      onChanged: model.updateEmail,
      readOnly: model.googleAuthModel != null || model.appleSignInModel != null
          ? true
          : false,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'jane@doe.com',
        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
        filled: model.googleAuthModel != null || model.appleSignInModel != null
            ? false
            : true,
        prefixIcon: Icon(
          Icons.email,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        border: InputBorder.none,
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      autocorrect: false,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: model.updatePassword,
      style: TextStyle(
        color: Color.fromRGBO(80, 80, 80, 1),
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        border: InputBorder.none,
        errorText: model.passwordErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      autocorrect: false,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: model.updateConfirmPassword,
      style: TextStyle(
        color: Color.fromRGBO(80, 80, 80, 1),
      ),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        filled: true,
        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        errorText: model.confirmPasswordErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      title: Title(
        color: Colors.blue,
        child: SuperRichText(
          text:
              'I agree to Medicall’s <terms>Terms & Conditions<terms>. I have reviewed the <privacy>Privacy Policy<privacy> and understand the benefits and risks of remote treatment.',
          style: TextStyle(color: Colors.black87, fontSize: 14),
          othersMarkers: [
            MarkerText.withSameFunction(
              marker: '<terms>',
              function: () => Navigator.of(context).pushNamed('/terms'),
              onError: (msg) => print('$msg'),
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            MarkerText.withSameFunction(
              marker: '<privacy>',
              function: () => Navigator.of(context).pushNamed('/privacy'),
              onError: (msg) => print('$msg'),
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
      value: model.checkValue,
      onChanged: model.updateCheckValue,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.blue,
    );
  }

  void _showFlushBarMessage(String message) {
    AppUtil().showFlushBar(message, context);
  }

  @override
  void updateStatus(String msg) {
    _showFlushBarMessage(msg);
  }
}
