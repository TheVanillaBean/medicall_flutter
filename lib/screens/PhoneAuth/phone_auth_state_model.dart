import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AuthStatus {
  STATE_INITIALIZED,
  STATE_CODE_SENT,
  STATE_VERIFY_FAILED,
  STATE_VERIFY_SUCCESS,
  STATE_SIGN_IN_FAILED,
  STATE_SIGN_IN_SUCCESS,
}

class PhoneAuthStateModel with PhoneValidators, ChangeNotifier {
  AuthStatus status;
  String phoneNumber;
  String smsCode;
  bool submitted;
  bool isRefreshing;
  bool codeTimedOut;
  String verificationId;
  AuthCredential phoneAuthCredential;
  TempUserProvider tempUserProvider;

  final AuthBase auth;
  Duration timeoutDuration = Duration(seconds: 60);
  VerificationStatus verificationStatus;

  PhoneAuthStateModel({
    @required this.auth,
    this.status = AuthStatus.STATE_INITIALIZED,
    this.phoneNumber = '',
    this.smsCode = '',
    this.submitted = false,
    this.isRefreshing = false,
    this.codeTimedOut = false,
    this.verificationId = '',
    this.phoneAuthCredential,
  });

  void setTempUserProvider(TempUserProvider tempUserProvider) {
    this.tempUserProvider = tempUserProvider;
  }

  void setVerificationStatus(VerificationStatus verificationStatus) {
    this.verificationStatus = verificationStatus;
  }

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

  void updateSMSCode(String code) => updateWith(smsCode: code);

  Future<void> updateRefreshing(bool isRefreshing, bool isMounted) async {
    if (isRefreshing) {
      if (!isMounted) return;
      updateWith(isRefreshing: false);
    }
    updateWith(isRefreshing: isRefreshing);
  }

  Future<void> verifyPhoneNumber(bool mounted) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      updateRefreshing(false, mounted);
      updateWith(
        phoneAuthCredential: phoneAuthCredential,
        status: AuthStatus.STATE_VERIFY_SUCCESS,
      );
      this.verificationStatus.updateStatus(
          'Phone number successfully verified in background. Please wait...');
      signInWithPhoneAuthCredential(mounted);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      updateRefreshing(false, mounted);
      updateWith(
        status: AuthStatus.STATE_VERIFY_FAILED,
      );
      this.verificationStatus.updateStatus(
          'Phone number verification failed. ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) {
      updateRefreshing(false, mounted);
      updateWith(
        verificationId: verificationId,
        status: AuthStatus.STATE_CODE_SENT,
      );
      this.verificationStatus.updateStatus(
          'An SMS text message code has been sent to your phone number.');
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      updateRefreshing(false, mounted);
      updateWith(verificationId: verificationId, codeTimedOut: true);
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: this.timeoutDuration,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<void> signInWithPhoneAuthCredential(bool mounted) async {
    try {
      MedicallUser user;
      this.auth.triggerAuthStream = false;

      if (this.tempUserProvider.googleAuthModel != null) {
        user = await this.auth.signInWithGoogle(
            credential: this.tempUserProvider.googleAuthModel.credential);
      } else {
        user = await this.auth.createUserWithEmailAndPassword(
            email: this.tempUserProvider.medicallUser.email,
            password: this.tempUserProvider.password);
      }

      this.phoneAuthCredential = this.phoneAuthCredential ??
          await auth.fetchPhoneAuthCredential(
              verificationId: this.verificationId, smsCode: this.smsCode);

      user = await auth.linkCredentialWithCurrentUser(
          credential: this.phoneAuthCredential);

      this.tempUserProvider.updateWith(
            uid: user.uid,
            devTokens: user.devTokens,
            phoneNumber: user.phoneNumber,
          );

      this.verificationStatus.updateStatus('Saving User Details...');

      bool successfullySavedImages =
          await tempUserProvider.saveRegistrationImages();

      this.auth.triggerAuthStream = true;

      if (successfullySavedImages) {
        await this.tempUserProvider.addNewUserToFirestore();
        this.auth.addUserToAuthStream(user: user);
      } else {
        updateRefreshing(false, mounted);
        throw PlatformException(
          code: 'ERROR_PHONE_AUTH_FAILED',
          message: 'Failed to create user account.',
        );
      }
    } catch (e) {
      this.auth.triggerAuthStream = true;
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
    AuthCredential phoneAuthCredential,
  }) {
    this.status = status ?? this.status;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.smsCode = smsCode ?? this.smsCode;
    this.submitted = submitted ?? this.submitted;
    this.isRefreshing = isRefreshing ?? this.isRefreshing;
    this.codeTimedOut = codeTimedOut ?? this.codeTimedOut;
    this.verificationId = verificationId ?? this.verificationId;
    this.phoneAuthCredential = phoneAuthCredential ?? this.phoneAuthCredential;
    notifyListeners();
  }
}

mixin VerificationStatus {
  void updateStatus(String msg);
}
