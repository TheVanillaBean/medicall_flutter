import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/screens/shared/password_reset/reset_password_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PasswordResetScreen extends StatefulWidget {
  static Widget create(BuildContext context) {
    final AuthBase _auth = Provider.of<AuthBase>(context);

    return ChangeNotifierProvider<ResetPasswordStateModel>(
      create: (context) => ResetPasswordStateModel(
        auth: _auth,
      ),
      child: Consumer<ResetPasswordStateModel>(
        builder: (_, model, __) => PasswordResetScreen(
          model: model,
        ),
      ),
    );
  }

  final ResetPasswordStateModel model;

  PasswordResetScreen({@required this.model});

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  ResetPasswordStateModel get model => widget.model;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    try {
      await model.submit();
      AppUtil().showFlushBar(
          "A password reset email has bent sent to your email.", context);
    } on PlatformException catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Reset Password"),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      Text("Please enter your email to reset your password."),
      Container(
          margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
          child: _buildEmailTextField(context)),
      Container(
          margin: EdgeInsets.fromLTRB(60, 0, 60, 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SignInButton(
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                  text: "Reset Password",
                  onPressed: model.canSubmit ? () => _submit(context) : null,
                ),
              )
            ],
          )),
    ];
  }

  TextField _buildEmailTextField(BuildContext context) {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onEditingComplete: () => _submit(context),
      onChanged: model.updateEmail,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.grey.withAlpha(20),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
        ),
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
