import 'dart:async';

import 'package:Medicall/components/masked_text.dart';
import 'package:Medicall/components/reactive_refresh_indicator.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  final PhoneAuthStateModel model;

  const PhoneAuthScreen({@required this.model});

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<PhoneAuthStateModel>(
      create: (context) => PhoneAuthStateModel(auth: auth),
      child: Consumer<PhoneAuthStateModel>(
        builder: (_, model, __) => PhoneAuthScreen(
          model: model,
        ),
      ),
    );
  }

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 1) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 3) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 2) + ' ');
      if (newValue.selection.end >= 2) selectionIndex += 1;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with VerificationError {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  PhoneAuthStateModel get model => widget.model;

  @override
  void dispose() {
    smsCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  _showErrorSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Widgets
  final decorationStyle = TextStyle(color: Colors.grey[50], fontSize: 16.0);
  final hintStyle = TextStyle(color: Colors.white24);

  Widget _buildConfirmPhoneButton() {
    return IconButton(
      icon: Icon(
        Icons.check_circle,
        size: 50,
      ),
      padding: EdgeInsets.all(10),
      color: Colors.white,
      disabledColor: Theme.of(context).buttonColor,
      onPressed: (model.status != AuthStatus.PHONE_AUTH)
          ? null
          : () => model.updateRefreshing(true, mounted),
    );
  }

  Widget _buildConfirmSMSCodeButton() {
    return IconButton(
      icon: Icon(
        Icons.check_circle,
        size: 50,
      ),
      padding: EdgeInsets.all(10),
      color: Colors.white,
      disabledColor: Theme.of(context).buttonColor,
      onPressed: (model.status != AuthStatus.SMS_AUTH)
          ? null
          : () async {
              var auth = Provider.of<AuthBase>(context);
              await auth.signUp();
              model.updateRefreshing(true, mounted);
            },
    );
  }

  Widget _buildPhoneNumberInput() {
    return MaskedTextField(
      mask: "(xxx)xxx-xxxx",
      keyboardType: TextInputType.phone,
      maskedTextFieldController: phoneNumberController,
      maxLength: 13,
      onSubmitted: (_) => model.updateRefreshing(true, mounted),
      onChanged: model.updatePhoneNumber,
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .subhead
          .copyWith(fontSize: 18.0, color: Colors.white),
      inputDecoration: InputDecoration(
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent)),
        isDense: false,
        counterText: "",
        icon: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        labelText: "Phone",
        labelStyle: decorationStyle,
        hintText: "(999)999-9999",
        hintStyle: hintStyle,
        errorText: model.phoneNumberErrorText,
        enabled: model.status == AuthStatus.PHONE_AUTH,
      ),
    );
  }

  Widget _buildPhoneAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Text(
            "We'll send an SMS message to verify your identity, please enter your phone number below!",
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 160),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 5,
                child: _buildPhoneNumberInput(),
              ),
              Flexible(
                flex: 1,
                child: _buildConfirmPhoneButton(),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCodeInput() {
    final enabled = model.status == AuthStatus.SMS_AUTH;
    var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            controller: smsCodeController,
            onChanged: model.updateSMSCode,
            maxLength: 6,
            onSubmitted: (_) async {
              await auth.signUp();
              model.updateRefreshing(true, mounted);
            },
            style: Theme.of(context).textTheme.subhead.copyWith(
                  fontSize: 32.0,
                  color: enabled ? Colors.white : Theme.of(context).buttonColor,
                ),
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent),
              ),
              counterText: "",
              hintText: "--- ---",
              hintStyle: hintStyle.copyWith(fontSize: 42.0),
              errorText: model.smsCodeErrorText,
              enabled: enabled,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildResendSmsWidget() {
    return InkWell(
      onTap: () async {
        if (model.codeTimedOut) {
          await model.verifyPhoneNumber(mounted, this);
        } else {
          _showErrorSnackbar("You can't retry yet!");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "If your code does not arrive in 1 minute, touch",
            style: decorationStyle,
            children: <TextSpan>[
              TextSpan(
                text: " here",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmsAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            "Verification code",
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 64.0),
          child: Flex(
            direction: Axis.horizontal,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 10, child: _buildSmsCodeInput()),
              Flexible(flex: 1, child: _buildConfirmSMSCodeButton())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _buildResendSmsWidget(),
        )
      ],
    );
  }

  Widget _buildBody() {
    Widget body;
    switch (model.status) {
      case AuthStatus.PHONE_AUTH:
        body = _buildPhoneAuthBody();
        break;
      case AuthStatus.SMS_AUTH:
        body = _buildSmsAuthBody();
        break;
    }
    return body;
  }

  Future<void> _onRefresh() async {
    if (model.status == AuthStatus.PHONE_AUTH) {
      try {
        return await model.verifyPhoneNumber(mounted, this);
      } on PlatformException catch (e) {
        _showErrorSnackbar(e.message);
      }
    }

    if (model.status == AuthStatus.SMS_AUTH) {
      try {
        return await model.signInWithPhoneNumber(mounted);
      } on PlatformException catch (e) {
        _showErrorSnackbar(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(elevation: 0.0),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: ReactiveRefreshIndicator(
          onRefresh: _onRefresh,
          color: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.background,
          isRefreshing: model.isRefreshing,
          child: Container(
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  @override
  void onVerificationError(String msg) {
    _showErrorSnackbar(msg);
  }
}
