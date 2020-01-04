import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';

enum AuthStatus { PHONE_AUTH, SMS_AUTH, PROFILE_AUTH }

class PhoneAuthStateModel with PhoneValidators, ChangeNotifier {
  AuthStatus status = AuthStatus.PHONE_AUTH;
  String phoneNumber;
  String smsCode;
  String errorMessage;
  String verificationId;
  bool submitted;
  bool isRefreshing;
  bool codeTimedOut;
  bool codeVerified;

  final AuthBase auth;

  PhoneAuthStateModel({
    @required this.auth,
    this.phoneNumber = '',
    this.smsCode = '',
    this.errorMessage = '',
    this.verificationId = '',
    this.isRefreshing = false,
    this.submitted = false,
    this.codeTimedOut = false,
    this.codeVerified = false,
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

  void updatePhoneNumber(String number) => updateWith(phoneNumber: number);
  void updateSMSCode(String code) => updateWith(smsCode: code);

  void updateWith({
    String phoneNumber,
    String smsCode,
    String errorMessage,
    String verificationId,
    bool isRefreshing,
    bool submitted,
    bool codeTimedOut,
    bool codeVerified,
  }) {
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.smsCode = smsCode ?? this.smsCode;
    this.errorMessage = errorMessage ?? this.errorMessage;
    this.verificationId = verificationId ?? this.verificationId;
    this.isRefreshing = isRefreshing ?? this.isRefreshing;
    this.submitted = submitted ?? this.submitted;
    this.codeTimedOut = codeTimedOut ?? this.codeTimedOut;
    this.codeVerified = codeVerified ?? this.codeVerified;
    notifyListeners();
  }
}
