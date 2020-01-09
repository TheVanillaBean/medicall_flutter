import 'dart:async';

import 'package:Medicall/util/firebase_listenter.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:Medicall/globals.dart' as globals;

class FirebasePhoneUtil {
  static final FirebasePhoneUtil _instance = FirebasePhoneUtil.internal();

  FirebasePhoneUtil.internal();

  factory FirebasePhoneUtil() {
    return _instance;
  }

  FirebaseAuthListener _view;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;
  FirebaseUser user;
  int seconds;
  AuthException authException;
  PhoneCodeSent codeSent;
  PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;
  PhoneVerificationFailed verificationFailed;
  PhoneVerificationCompleted verificationCompleted;

  setScreenListener(FirebaseAuthListener view) {
    _view = view;
  }

  Future<void> verifyPhoneNumber(String phoneNumber, String code) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential user) {};

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      _view.onError(authException.message);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      _view.verificationCodeSent(forceResendingToken);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _view.onError(verificationId);
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: code + phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  verifyOtp(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    final FirebaseUser currentUser = await _auth.currentUser();
    if (!identical(user.uid, currentUser.uid)) {
      onLoginUserVerified(currentUser);
    }
  }

  void onLoginUserVerified(FirebaseUser currentUser) {
    _view.onLoginUserVerified(currentUser);
  }

  onTokenError(String string) {
    print('libs ' + string);
  }
}
