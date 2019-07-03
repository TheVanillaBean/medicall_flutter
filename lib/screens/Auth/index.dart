import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:Medicall/components/logger.dart';
import 'package:Medicall/screens/Registration/RegistrationType/index.dart';
import 'package:Medicall/components/masked_text.dart';
import 'package:Medicall/components/reactive_refresh_indicator.dart';

enum AuthStatus { PHONE_AUTH, SMS_AUTH, PROFILE_AUTH }

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const String TAG = "AUTH";
  AuthStatus status = AuthStatus.PHONE_AUTH;
  StreamSubscription<DocumentSnapshot> subscription;

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<MaskedTextFieldState> _maskedPhoneKey =
      GlobalKey<MaskedTextFieldState>();

  // Controllers
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  // Variables
  String _phoneNumber;
  String _errorMessage;
  String _verificationId;
  Timer _codeTimer;

  bool _isRefreshing = false;
  bool _codeTimedOut = false;
  bool _codeVerified = false;
  Duration _timeOut = const Duration(minutes: 1);

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _codeTimer?.cancel();
    super.dispose();
    smsCodeController.dispose();
    phoneNumberController.dispose();
    subscription?.cancel();
  }

  // PhoneVerificationFailed
  verificationFailed(AuthException authException) {
    _showErrorSnackbar(
        "We couldn't verify your code for now, please try again!");
    Logger.log(TAG,
        message:
            'onVerificationFailed, code: ${authException.code}, message: ${authException.message}');
  }

  void _add(user) {
    medicallUser.id = user.uid;
    medicallUser.displayName = user.displayName;
    medicallUser.firstName =
        user.displayName != null ? user.displayName.split(' ')[0] : '';
    medicallUser.lastName =
        user.displayName != null ? user.displayName.split(' ')[1] : '';
    medicallUser.email = user.email;
    medicallUser.phoneNumber = user.phoneNumber;
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + user.uid);
    Map<String, String> data = <String, String>{
      "name": user.displayName,
      "first_name": medicallUser.firstName,
      "last_name": medicallUser.lastName,
      "email": user.email,
      "phone": user.phoneNumber
    };
    documentReference.setData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  // PhoneCodeSent
  codeSent(String verificationId, [int forceResendingToken]) async {
    Logger.log(TAG,
        message:
            "Verification code sent to number ${phoneNumberController.text}");
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this.status = AuthStatus.SMS_AUTH;
      Logger.log(TAG, message: "Changed status to $status");
    });
  }

  // PhoneCodeAutoRetrievalTimeout
  codeAutoRetrievalTimeout(String verificationId) {
    Logger.log(TAG, message: "onCodeTimeout");
    _updateRefreshing(false);
    if (!mounted) return;
    setState(() {
      this._verificationId = verificationId;
      this._codeTimedOut = true;
    });
  }

  // Styling

  final decorationStyle = TextStyle(color: Colors.grey[50], fontSize: 16.0);
  final hintStyle = TextStyle(color: Colors.white24);

  // async

  Future<Null> _updateRefreshing(bool isRefreshing) async {
    Logger.log(TAG,
        message: "Setting _isRefreshing ($_isRefreshing) to $isRefreshing");
    if (_isRefreshing) {
      if (!mounted) return;
      setState(() {
        this._isRefreshing = false;
      });
    }
    setState(() {
      this._isRefreshing = isRefreshing;
    });
  }

  _showErrorSnackbar(String message) {
    _updateRefreshing(false);
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Future<Null> _signIn() async {
  //   GoogleSignInAccount user = _googleSignIn.currentUser;
  //   Logger.log(TAG, message: "Just got user as: $user");

  //   final onError = (exception, stacktrace) {
  //     Logger.log(TAG, message: "Error from _signIn: $exception");
  //     _showErrorSnackbar(
  //         "Couldn't log in with your Google account, please try again!");
  //     user = null;
  //   };

  //   if (user == null) {
  //     user = await _googleSignIn.signIn().catchError(onError);
  //     Logger.log(TAG, message: "Received $user");
  //     final GoogleSignInAuthentication googleAuth = await user.authentication;
  //     Logger.log(TAG, message: "Added googleAuth: $googleAuth");
  //     _firebaseUser = await _auth
  //         .signInWithCredential(GoogleAuthProvider.getCredential(
  //           accessToken: googleAuth.accessToken,
  //           idToken: googleAuth.idToken,
  //         ))
  //         .catchError(onError);
  //   }

  //   if (user != null) {
  //     _updateRefreshing(false);
  //     _googleUser = user;
  //     setState(() {
  //       this.status = AuthStatus.PHONE_AUTH;
  //       Logger.log(TAG, message: "Changed status to $status");
  //     });
  //     return null;
  //   }
  //   return null;
  // }

  Future<Null> _submitPhoneNumber() async {
    final error = _phoneInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = error;
      });
      return null;
    } else {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = null;
      });
      final result = await _verifyPhoneNumber();
      Logger.log(TAG, message: "Returning $result from _submitPhoneNumber");
      return result;
    }
  }

  String get phoneNumber {
    try {
      String unmaskedText = _maskedPhoneKey.currentState?.unmaskedText;
      if (unmaskedText != null) _phoneNumber = "+1$unmaskedText".trim();
    } catch (error) {
      Logger.log(TAG,
          message: "Couldn't access state from _maskedPhoneKey: $error");
    }
    return _phoneNumber;
  }

  Future<Null> _verifyPhoneNumber() async {
    FirebaseUser user = await _auth.currentUser();
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      Logger.log(TAG, message: "onVerificationCompleted, user: $user");
      if (await _onCodeVerified(user)) {
        await _finishSignIn(user);
      } else {
        setState(() {
          this.status = AuthStatus.SMS_AUTH;
          Logger.log(TAG, message: "Changed status to $status");
        });
      }
    };
    Logger.log(TAG, message: "Got phone number as: ${this.phoneNumber}");
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: _timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed);
    Logger.log(TAG, message: "Returning null from _verifyPhoneNumber");
    return null;
  }

  Future<Null> _submitSmsCode() async {
    final error = _smsInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      _showErrorSnackbar(error);
      return null;
    } else {
      if (this._codeVerified) {
        await _finishSignIn(await _auth.currentUser());
      } else {
        Logger.log(TAG, message: "_signInWithPhoneNumber called");
        await _signInWithPhoneNumber();
      }
      return null;
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    final errorMessage = "We couldn't verify your code, please try again!";
    FirebaseUser user = await _auth.currentUser();
    await user
        .linkWithCredential(
      PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: smsCodeController.text,
      ),
    )
        .then((user) async {
      await _onCodeVerified(user).then((codeVerified) async {
        this._codeVerified = codeVerified;
        Logger.log(
          TAG,
          message: "Returning ${this._codeVerified} from _onCodeVerified",
        );
        if (this._codeVerified) {
          await _finishSignIn(user);
        } else {
          _showErrorSnackbar(errorMessage);
        }
      });
    }, onError: (error) {
      print("Failed to verify SMS code: $error");
      _showErrorSnackbar(error.message);
    });
  }

  Future<bool> _onCodeVerified(FirebaseUser user) async {
    final isUserValid = (user != null &&
        (user.phoneNumber != null && user.phoneNumber.isNotEmpty));
    if (isUserValid) {
      setState(() {
        // Here we change the status once more to guarantee that the SMS's
        // text input isn't available while you do any other request
        // with the gathered data
        this.status = AuthStatus.PROFILE_AUTH;
        Logger.log(TAG, message: "Changed status to $status");
      });
    } else {
      _showErrorSnackbar("We couldn't verify your code, please try again!");
    }
    return isUserValid;
  }

  _finishSignIn(FirebaseUser user) async {
    await _onCodeVerified(user).then((result) {
      if (result) {
        // Here, instead of navigating to another screen, you should do whatever you want
        // as the user is already verified with Firebase from both
        // Google and phone number methods
        // Example: authenticate with your own API, use the data gathered
        // to post your profile/user, etc.
        _add(user);
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => RegistrationTypeScreen(
                data: {"user": medicallUser},
              ),
        ));
      } else {
        setState(() {
          this.status = AuthStatus.SMS_AUTH;
        });
        _showErrorSnackbar(
            "We couldn't create your profile for now, please try again later");
      }
    });
  }

  // Widgets

  Widget _buildConfirmInputButton() {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.check),
      color: Colors.white,
      disabledColor: theme.buttonColor,
      onPressed: (this.status == AuthStatus.PROFILE_AUTH)
          ? null
          : () => _updateRefreshing(true),
    );
  }

  Widget _buildPhoneNumberInput() {
    return MaskedTextField(
      key: _maskedPhoneKey,
      mask: "(xxx) xxx-xxxx",
      keyboardType: TextInputType.number,
      maskedTextFieldController: phoneNumberController,
      maxLength: 14,
      onSubmitted: (text) => _updateRefreshing(true),
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
        enabled: this.status == AuthStatus.PHONE_AUTH,
        counterText: "",
        icon: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        labelText: "Phone",
        labelStyle: decorationStyle,
        hintText: "(999) 999-9999",
        hintStyle: hintStyle,
        errorText: _errorMessage,
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
            "We'll send an SMS message to verify your identity, please enter your code below!",
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
              Flexible(flex: 5, child: _buildPhoneNumberInput()),
              Flexible(flex: 1, child: _buildConfirmInputButton())
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCodeInput() {
    final enabled = this.status == AuthStatus.SMS_AUTH;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            keyboardType: TextInputType.number,
            enabled: enabled,
            textAlign: TextAlign.center,
            controller: smsCodeController,
            maxLength: 6,
            onSubmitted: (text) => _updateRefreshing(true),
            style: Theme.of(context).textTheme.subhead.copyWith(
                  fontSize: 32.0,
                  color: enabled ? Colors.white : Theme.of(context).buttonColor,
                ),
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent)),
              counterText: "",
              enabled: enabled,
              hintText: "--- ---",
              hintStyle: hintStyle.copyWith(fontSize: 42.0),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildResendSmsWidget() {
    return InkWell(
      onTap: () async {
        if (_codeTimedOut) {
          await _verifyPhoneNumber();
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
              Flexible(flex: 1, child: _buildConfirmInputButton())
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

  String _phoneInputValidator() {
    if (phoneNumberController.text.isEmpty) {
      return "Your phone number can't be empty!";
    } else if (phoneNumberController.text.length < 14) {
      return "This phone number is invalid!";
    }
    return null;
  }

  String _smsInputValidator() {
    if (smsCodeController.text.isEmpty) {
      return "Your verification code can't be empty!";
    } else if (smsCodeController.text.length < 6) {
      return "This verification code is invalid!";
    }
    return null;
  }

  Widget _buildBody() {
    Widget body;
    switch (this.status) {
      case AuthStatus.PHONE_AUTH:
        body = _buildPhoneAuthBody();
        break;
      case AuthStatus.SMS_AUTH:
        body = _buildSmsAuthBody();
        break;
      case AuthStatus.PROFILE_AUTH:
        body = _buildSmsAuthBody();
        break;
    }
    return body;
  }

  Future<Null> _onRefresh() async {
    switch (this.status) {
      case AuthStatus.PHONE_AUTH:
        return await _submitPhoneNumber();
        break;
      case AuthStatus.SMS_AUTH:
        return await _submitSmsCode();
        break;
      case AuthStatus.PROFILE_AUTH:
        break;
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
          isRefreshing: _isRefreshing,
          child: Container(child: _buildBody()),
        ),
      ),
    );
  }
}
