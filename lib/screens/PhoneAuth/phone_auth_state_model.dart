import 'dart:async';

import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
  GlobalKey<FormBuilderState> userRegKey;

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
    this.userRegKey,
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

  void updatePhoneNumber(String number) {
    if (number.length <= 13) {
      updateWith(phoneNumber: '+1$number'.trim());
    }
  }

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
      User user;
      this.auth.triggerAuthStream = false;

      this.phoneAuthCredential = this.phoneAuthCredential ??
          await auth.fetchPhoneAuthCredential(
              verificationId: this.verificationId, smsCode: this.smsCode);

      this.verificationStatus.updateStatus('Performing Security Check...');

      bool emailAlreadyUsed = await auth.emailAlreadyUsed(
          email: this.tempUserProvider.medicallUser.email);

      if (emailAlreadyUsed) {
        this.auth.triggerAuthStream = true;
        reinitState();
        updateRefreshing(false, mounted);
        throw 'This email address is taken.';
      }

      bool phoneNumberAlreadyUsed =
          await auth.phoneNumberAlreadyUsed(phoneNumber: this.phoneNumber);

      if (phoneNumberAlreadyUsed) {
        this.auth.triggerAuthStream = true;
        reinitState();
        updateRefreshing(false, mounted);
        throw 'This phone number has already been used. Please use a different number.';
      } else {
        this.verificationStatus.updateStatus('Creating Account...');

        user = await auth.signInWithPhoneNumber(
            credential: this.phoneAuthCredential);

        if (user == null) {
          this.auth.triggerAuthStream = true;
          reinitState();
          updateRefreshing(false, mounted);
          throw "The SMS code you entered is invalid. Please try again...";
        }

        FirebaseUser currentFirebaseUser;

        if (this.tempUserProvider.googleAuthModel != null) {
          currentFirebaseUser = await auth.linkCredentialWithCurrentUser(
              credential: this.tempUserProvider.googleAuthModel.credential);
        } else if (this.tempUserProvider.appleSignInModel != null) {
          currentFirebaseUser = await auth.linkCredentialWithCurrentUser(
              credential: this.tempUserProvider.appleSignInModel.credential);
        } else {
          AuthCredential emailCredential =
              await auth.fetchEmailAndPasswordCredential(
            email: this.tempUserProvider.medicallUser.email,
            password: this.tempUserProvider.password,
          );
          currentFirebaseUser = await auth.linkCredentialWithCurrentUser(
              credential: emailCredential);
        }

        this.tempUserProvider.updateWith(
              uid: user.uid,
              devTokens: user.devTokens,
              phoneNumber: user.phoneNumber,
            );

        this.verificationStatus.updateStatus(
            'Saving User Details. This may take several seconds...');

        // bool successfullySavedImages =
        //     await tempUserProvider.saveRegistrationImages();

        this.auth.triggerAuthStream = true;
//        await this.tempUserProvider.addNewUserToFirestore();
        await this.tempUserProvider.addProviderMalPractice();
        currentFirebaseUser.sendEmailVerification();
//        this.auth.addUserToAuthStream(user: user);
        // if (successfullySavedImages) {

        // } else {
        //   this.auth.triggerAuthStream = true;
        //   reinitState();
        //   updateRefreshing(false, mounted);
        //   throw PlatformException(
        //     code: 'ERROR_PHONE_AUTH_FAILED',
        //     message: 'Failed to create user account.',
        //   );
        // }
      }
    } on CloudFunctionsException {
      this.auth.triggerAuthStream = true;
      reinitState();
      updateRefreshing(false, mounted);
      throw "Security Check Failed...";
    } on PlatformException catch (e) {
      this.auth.triggerAuthStream = true;
      reinitState();
      updateRefreshing(false, mounted);
      if (e.code == "ERROR_INVALID_VERIFICATION_CODE") {
        throw "The SMS code you entered is invalid...";
      } else if (e.message.toLowerCase().contains('The sms code has expired')) {
        throw "The SMS code has expired.";
      } else
        throw e.message;
    } catch (e) {
      this.auth.triggerAuthStream = true;
      reinitState();
      updateRefreshing(false, mounted);
      rethrow;
    }
  }

  void reinitState() {
    updateWith(
      status: AuthStatus.STATE_INITIALIZED,
      phoneNumber: '',
      smsCode: '',
      submitted: false,
      codeTimedOut: false,
      verificationId: '',
      phoneAuthCredential: null,
    );
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
