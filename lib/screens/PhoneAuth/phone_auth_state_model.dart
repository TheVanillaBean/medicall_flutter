import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AuthStatus { PHONE_AUTH, SMS_AUTH }

class PhoneAuthStateModel with PhoneValidators, ChangeNotifier {
  AuthStatus status;
  String phoneNumber;
  String smsCode;
  bool submitted;
  bool isRefreshing;
  bool codeTimedOut;
  String verificationId;
  AuthCredential authCredential;

  final AuthBase auth;
  Duration timeoutDuration = Duration(milliseconds: 5000);
  VerificationStatus verificationStatus;

  PhoneAuthStateModel({
    @required this.auth,
    this.status = AuthStatus.PHONE_AUTH,
    this.phoneNumber = '',
    this.smsCode = '',
    this.submitted = false,
    this.isRefreshing = false,
    this.codeTimedOut = false,
    this.verificationId = '',
    this.authCredential,
  });

  bool get canSubmitPhoneNumber {
    return phoneNumberEmptyValidator.isValid(phoneNumber) &&
        phoneNumberLengthValidator.isValid(phoneNumber) &&
        !isRefreshing;
  }

  bool get canSubmitSMSCode {
    return codeEmptyValidator.isValid(smsCode) &&
        codeLengthValidator.isValid(smsCode) &&
        !isRefreshing;
  }

  String get phoneNumberErrorText {
    bool showEmptyText =
        submitted && !phoneNumberEmptyValidator.isValid(phoneNumber);
    bool showLengthText =
        submitted && !phoneNumberLengthValidator.isValid(phoneNumber);

    if (showLengthText) {
      if (showEmptyText) {
        return emptyPhoneNumberErrorText;
      }
      return phoneNumberLengthErrorText;
    }
    return null;
  }

  String get smsCodeErrorText {
    bool showEmptyText = submitted && !codeEmptyValidator.isValid(smsCode);
    bool showLengthText = submitted && !codeLengthValidator.isValid(smsCode);

    if (showLengthText) {
      if (showEmptyText) {
        return emptyCodeErrorText;
      }
      return codeLengthErrorText;
    }
    return null;
  }

  void updatePhoneNumber(String number) =>
      updateWith(phoneNumber: '+1$number'.trim());
  void updateSMSCode(String code) {
    updateWith(smsCode: code);
  }

  Future<void> updateRefreshing(bool isRefreshing, bool isMounted) async {
    if (isRefreshing) {
      if (!isMounted) return;
      updateWith(isRefreshing: false);
    }
    updateWith(isRefreshing: isRefreshing);
  }

  Future<void> verifyPhoneNumber(
      bool mounted, VerificationStatus verificationError) async {
    this.verificationStatus = verificationError;
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      updateWith(
          authCredential: phoneAuthCredential,
          status: AuthStatus
              .SMS_AUTH); //this won't actually change anything as the user will be redirected anyway.
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      updateRefreshing(false, mounted);
      this.verificationStatus.onVerificationError(
          'Phone number verification failed. ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) {
      // Timer _ = Timer(this.timeoutDuration, () {
      //   updateWith(codeTimedOut: true);
      //   this.verificationStatus.onVerificationError(
      //       'Your phone verification session has timed out. Retry to receive another code.');
      // });
      updateWith(
        verificationId: verificationId,
        status: AuthStatus.SMS_AUTH,
      );
      updateRefreshing(false, mounted);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      updateRefreshing(false, mounted);
      updateWith(verificationId: verificationId, codeTimedOut: true);
      this.verificationStatus.onVerificationError(
          'Your phone verification session has timed out. Retry to receive another code.');
    };

    await firebaseAuth
        .verifyPhoneNumber(
            phoneNumber: this.phoneNumber,
            timeout: this.timeoutDuration,
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .then((onValue) {
      print('d');
    });
  }

  Future<void> signInWithPhoneNumber(
      bool mounted, TempUserProvider tempUserProvider) async {
    try {
      auth.newUser = true;

      MedicallUser user = await auth.createUserWithEmailAndPassword(
          tempUserProvider.medicallUser.email, tempUserProvider.password);

      user =
          await auth.signInWithPhoneNumber(this.verificationId, this.smsCode);

      tempUserProvider.updateWith(
        uid: user.uid,
        devTokens: user.devTokens,
        phoneNumber: user.phoneNumber,
      );

      this.verificationStatus.onVerificationSuccess("Saving User Details...");

      bool successfullySavedImages =
          await tempUserProvider.saveRegistrationImages();

      if (successfullySavedImages) {
        await tempUserProvider.addNewUserToFirestore();
        auth.newUser = false;
        auth.addUserToAuthStream(user);
      } else {
        updateRefreshing(false, mounted);
        throw PlatformException(
          code: 'ERROR_PHONE_AUTH_FAILED',
          message: 'Failed to create user account.',
        );
      }
    } catch (e) {
      updateRefreshing(false, mounted);
      rethrow;
    }
  }

  void updateWith({
    AuthStatus status,
    String phoneNumber,
    String smsCode,
    bool submitted,
    bool isRefreshing,
    bool codeTimedOut,
    String verificationId,
    AuthCredential authCredential,
  }) {
    this.status = status ?? this.status;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.smsCode = smsCode ?? this.smsCode;
    this.submitted = submitted ?? this.submitted;
    this.isRefreshing = isRefreshing ?? this.isRefreshing;
    this.codeTimedOut = codeTimedOut ?? this.codeTimedOut;
    this.verificationId = verificationId ?? this.verificationId;
    this.authCredential = authCredential ?? this.authCredential;
    notifyListeners();
  }
}

mixin VerificationStatus {
  void onVerificationError(String msg);
  void onVerificationSuccess(String msg);
}
