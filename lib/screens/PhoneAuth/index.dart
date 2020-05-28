import 'dart:async';

import 'package:Medicall/components/reactive_refresh_indicator.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  final PhoneAuthStateModel model;

  const PhoneAuthScreen({@required this.model});

  static Widget create(
      BuildContext context, GlobalKey<FormBuilderState> regKey) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<PhoneAuthStateModel>(
      create: (context) => PhoneAuthStateModel(auth: auth, userRegKey: regKey),
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

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with VerificationStatus {
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  MaskTextInputFormatter phoneTextInputFormatter = MaskTextInputFormatter(
      mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});

  PhoneAuthStateModel get model => widget.model;
  TempUserProvider tempUserProvider;

  @override
  void dispose() {
    smsCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  // Widgets
  final decorationStyle = TextStyle(color: Colors.black45, fontSize: 16.0);
  final hintStyle = TextStyle(color: Colors.black26);

  Widget _buildInputButton(bool condition) {
    return FlatButton(
      padding: EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.secondary,
      disabledColor: Theme.of(context).buttonColor,
      textColor: Colors.white,
      child: Text(
        'Continue',
        style: TextStyle(fontSize: 18),
      ),
      onPressed: (condition)
          ? () {
              bool successfullySaveForm =
                  widget.model.userRegKey.currentState.saveAndValidate();
              if (successfullySaveForm &&
                      widget.model.userRegKey.currentState
                          .value['Terms and conditions']
                  //     &&
                  // widget.model.userRegKey.currentState
                  //     .value['accept_privacy_switch']
                  ) {
                updateUserWithFormData(tempUserProvider);
                model.updateRefreshing(true, mounted);
                //Navigator.of(context).pushNamed('/startVisit');
              } else {
                if (!widget.model.userRegKey.currentState
                    .value['Terms and conditions']) {
                  AppUtil().showFlushBar(
                      'Please accept the "Terms & Conditions" to continue.',
                      context);
                }
                // if (!widget.model.userRegKey.currentState
                //     .value['accept_privacy_switch']) {
                //   AppUtil().showFlushBar(
                //       'Please accept the "Privacy Policy" to continue.',
                //       context);
                // }
              }
            }
          : null,
    );
  }

  Widget _buildPhoneNumberInput() {
    return TextField(
      controller: phoneNumberController,
      inputFormatters: [phoneTextInputFormatter],
      autocorrect: false,
      keyboardType: TextInputType.phone,
      maxLength: 13,
      onSubmitted: (_) {
        model.updateRefreshing(true, mounted);
      },
      onChanged: model.updatePhoneNumber,
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .subtitle1
          .copyWith(fontSize: 18.0, color: Colors.black),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        isDense: false,
        counterText: "",
        icon: const Icon(
          Icons.phone,
          color: Colors.black,
        ),
        labelText: "Phone",
        labelStyle: decorationStyle,
        hintText: "(###)###-####",
        hintStyle: hintStyle,
        errorText: model.phoneNumberErrorText,
        enabled: model.status == AuthStatus.STATE_INITIALIZED,
      ),
    );
  }

  Widget _buildPhoneAuthBody() {
    final heightMargin = 10.0;
    return Container(
      height: 500,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, heightMargin, 0, 16),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              "We'll send an SMS message to verify your identity, please enter your phone number below!",
              style: decorationStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, heightMargin),
            child: _buildPhoneNumberInput(),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildInputButton(
                    model.status == AuthStatus.STATE_INITIALIZED &&
                        model.canSubmitPhoneNumber),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmsCodeInput() {
    final enabled = model.status == AuthStatus.STATE_CODE_SENT ||
        model.status == AuthStatus.STATE_VERIFY_FAILED ||
        model.status == AuthStatus.STATE_SIGN_IN_FAILED;
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      controller: smsCodeController,
      onChanged: model.updateSMSCode,
      maxLength: 6,
      onSubmitted: (_) {
        model.updateRefreshing(true, mounted);
      },
      style: Theme.of(context).textTheme.subtitle1.copyWith(
            fontSize: 32.0,
            color: enabled ? Colors.black : Theme.of(context).buttonColor,
          ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        counterText: "",
        hintText: "--- ---",
        hintStyle: hintStyle.copyWith(fontSize: 42.0),
        errorText: model.smsCodeErrorText,
        enabled: enabled,
      ),
    );
  }

  void updateUserWithFormData(TempUserProvider tempUserProvider) {
    tempUserProvider.updateWith(
      password: this.password,
      email: this.email,
      terms: this.terms,
      policy: this.policy,
      consent: this.consent,
    );
    // if (tempUserProvider.medicallUser.type == 'provider') {
    //   tempUserProvider.updateWith(
    //       titles: this.titles,
    //       npi: this.npi,
    //       medLicense: this.medLicense,
    //       medLicenseState: this.medLicenseState);
    // }
  }

  Widget _buildResendSmsWidget() {
    return InkWell(
      onTap: () async {
        if (model.codeTimedOut) {
          await model.verifyPhoneNumber(mounted);
        } else {
          _showFlushBarMessage("You can't retry yet!");
        }
      },
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
    );
  }

  Widget _buildSmsAuthBody() {
    final heightMargin = 15.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, heightMargin, 0, 16),
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Text(
            "Verification code",
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, heightMargin),
          child: _buildSmsCodeInput(),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildInputButton(
                  (model.status == AuthStatus.STATE_CODE_SENT ||
                          model.status == AuthStatus.STATE_VERIFY_FAILED ||
                          model.status == AuthStatus.STATE_SIGN_IN_FAILED) &&
                      model.canSubmitSMSCode),
            ),
          ],
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
    if (model.status == AuthStatus.STATE_INITIALIZED) {
      body = _buildPhoneAuthBody();
    }
    if (model.status == AuthStatus.STATE_CODE_SENT ||
        model.status == AuthStatus.STATE_VERIFY_FAILED ||
        model.status == AuthStatus.STATE_SIGN_IN_FAILED) {
      body = _buildSmsAuthBody();
    }
    return body;
  }

  Future<void> _onRefresh() async {
    if (model.status == AuthStatus.STATE_INITIALIZED) {
      try {
        return await model.verifyPhoneNumber(mounted);
      } catch (e) {
        phoneNumberController.text = "";
        smsCodeController.text = "";
        phoneTextInputFormatter = MaskTextInputFormatter(
            mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});
        AppUtil().showFlushBar(e, context);
      }
    }

    if (model.status == AuthStatus.STATE_CODE_SENT ||
        model.status == AuthStatus.STATE_VERIFY_FAILED ||
        model.status == AuthStatus.STATE_SIGN_IN_FAILED) {
      try {
        return await model.signInWithPhoneAuthCredential(mounted);
      } catch (e) {
        phoneNumberController.text = "";
        smsCodeController.text = "";
        phoneTextInputFormatter = MaskTextInputFormatter(
            mask: "(###)###-####", filter: {"#": RegExp(r'[0-9]')});
        AppUtil().showFlushBar(e, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    tempUserProvider = Provider.of<TempUserProvider>(context);
    model.setTempUserProvider(tempUserProvider);
    model.setVerificationStatus(this);

    return ReactiveRefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      isRefreshing: model.isRefreshing,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: _buildBody(),
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

  String get password {
    return widget.model.userRegKey.currentState.value['Password']
        .toString()
        .trim();
  }

  String get email {
    return widget.model.userRegKey.currentState.value['Email']
        .toString()
        .trim();
  }

  bool get terms {
    return widget.model.userRegKey.currentState.value['Terms and conditions'];
  }

  bool get policy {
    return widget.model.userRegKey.currentState.value['accept_privacy_switch'];
  }

  bool get consent {
    return widget.model.userRegKey.currentState.value['accept_consent'];
  }
}
