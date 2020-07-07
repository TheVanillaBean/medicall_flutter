import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Registration/Provider/provider_custom_text_field.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_form.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  final ProviderRegistrationViewModel model;

  const ProviderRegistrationScreen({@required this.model});

  static Widget create(BuildContext context) {
    final NonAuthDatabase db =
        Provider.of<NonAuthDatabase>(context, listen: false);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return ChangeNotifierProvider<ProviderRegistrationViewModel>(
      create: (context) => ProviderRegistrationViewModel(
        nonAuthDatabase: db,
        auth: auth,
        tempUserProvider: tempUserProvider,
      ),
      child: Consumer<ProviderRegistrationViewModel>(
        builder: (_, model, __) => ProviderRegistrationScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.providerRegistration);
  }

  @override
  _ProviderRegistrationScreenState createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen>
    with VerificationStatus {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  ProviderRegistrationViewModel get model => widget.model;

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
        model.tempUserProvider.updateWith(
          email: model.googleAuthModel.email,
          displayName: model.googleAuthModel.displayName,
          googleAuthModel: model.googleAuthModel,
        );
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
        model.tempUserProvider.updateWith(
          email: model.appleSignInModel.email,
          displayName: model.appleSignInModel.displayName,
          appleSignInModel: model.appleSignInModel,
        );
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
            );
          },
        ),
        title: Text(
          'Provider Registration',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
      ),
      //Content of tabs
      body: SingleChildScrollView(
        child: ProviderRegistrationForm(),
      ),
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
