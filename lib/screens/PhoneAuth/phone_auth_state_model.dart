import 'dart:async';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  Duration timeoutDuration = Duration(minutes: 1);
  VerificationError verificationError;

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
      bool mounted, VerificationError verificationError) async {
    this.verificationError = verificationError;
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
      this.verificationError.onVerificationError(
          'Phone number verification failed. ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) {
      Timer _ = Timer(this.timeoutDuration, () {
        updateWith(codeTimedOut: true);
        this.verificationError.onVerificationError(
            'Your phone verification session has timed out. Retry to receive another code.');
      });
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
      this.verificationError.onVerificationError(
          'Your phone verification session has timed out. Retry to receive another code.');
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: this.timeoutDuration,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  //move _add above signInWithPhoneNumber
  //move _add to UserProvider
  //rename _add to _createUser

  //MedicallUser medicallUser = TempUserProvider.medicallUser
  //medicallUser = _add(medicallUser, context)
  //medicallUser = auth.saveRegistrationImages(medicallUser);
  //await auth.signInWithPhoneNumber(this.verificationId, this.smsCode);

  //move _add and saveRegistrationImages to TempUserImage

  //UserProvider will have methods for updating UserProvider,
  // but TempUserProvider will have methods for creating a new user
  Future<MedicallUser> signInWithPhoneNumber(bool mounted, context) async {
    try {
      MedicallUser user =
          await auth.signInWithPhoneNumber(this.verificationId, this.smsCode);
      user = await auth.saveRegistrationImages(user);
      await _add(user, context);
      updateRefreshing(false, mounted);
      return user;
    } catch (e) {
      updateRefreshing(false, mounted);
      rethrow;
    }
  }

  Future<Null> _add(user, context) async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + user.uid);
    Map<String, dynamic> data = <String, dynamic>{
      "name": user.displayName,
      "first_name": user.firstName,
      "last_name": user.lastName,
      "email": user.email,
      "gender": user.gender,
      "type": user.type,
      "address": user.address,
      "terms": user.terms,
      "policy": user.policy,
      "consent": user.consent,
      "dob": user.dob,
      "phone": user.phoneNumber,
      "profile_pic": user.profilePic,
      "gov_id": user.govId,
      "dev_tokens": user.devTokens,
    };
    if (user.type == 'provider') {
      data['titles'] = user.titles;
      data['npi'] = user.npi;
      data['med_license'] = user.medLicense;
      data['state_issued'] = user.medLicenseState;
    }

    try {
      await documentReference.setData(data).then((onValue) {
        print('User added');
      });
    } catch (e) {
      throw e;
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

mixin VerificationError {
  void onVerificationError(String msg);
}

//throw exceptions are return user
//also check the firebase flutter auth repo and double check all other auth methods and see if anything is missing
//for example the identical check is missing in google auth

//add button to sign out user in PhoneAuthScreen, which will cause a auth update event and return to login

//move verifyPhoneNumber function at the bottom to auth.dart ---wait on this, just test if it works in this class and then move over
//create variables to hold authcrediential and verificationid and call notifylisteners()
