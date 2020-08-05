import 'package:Medicall/util/string_utils.dart';

abstract class StringValidator {
  bool isValid(String value);
}

class NonEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return StringUtils.isEmail(value);
  }
}

class StateValidator implements StringValidator {
  List<String> states = [
    "AK",
    "AL",
    "AR",
    "AS",
    "AZ",
    "CA",
    "CO",
    "CT",
    "DC",
    "DE",
    "FL",
    "GA",
    "GU",
    "HI",
    "IA",
    "ID",
    "IL",
    "IN",
    "KS",
    "KY",
    "LA",
    "MA",
    "MD",
    "ME",
    "MI",
    "MN",
    "MO",
    "MP",
    "MS",
    "MT",
    "NC",
    "ND",
    "NE",
    "NH",
    "NJ",
    "NM",
    "NV",
    "NY",
    "OH",
    "OK",
    "OR",
    "PA",
    "PR",
    "RI",
    "SC",
    "SD",
    "TN",
    "TX",
    "UM",
    "UT",
    "VA",
    "VI",
    "VT",
    "WA",
    "WI",
    "WV",
    "WY"
  ];
  @override
  bool isValid(String value) {
    return states.contains(value);
  }
}

class ProviderDobValidators {
  final StringValidator dobValidator = NonEmptyStringValidator();
  final String dobErrorText = 'Please enter a valid birthday (must be 18)';
}

class ProviderStateValidators {
  final StringValidator stateValidator = StateValidator();
  final String medStateErrorText =
      'Please enter a valid two letter state abbreviation code';
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = EmailValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final String invalidEmailErrorText = 'Incorrect email format';
  final String invalidPasswordErrorText = 'Password can\'t be empty';
  final String invalidConfirmPasswordErrorText = 'Passwords do not match';
}

class OptionInputValidator {
  final StringValidator inputValidator = NonEmptyStringValidator();
  final String invalidInputErrorText = 'Your response can\'t be empty';
}

class PersonalInfoValidator {
  final StringValidator inputValidator = NonEmptyStringValidator();
  final String invalidPersonalInfoErrorText = 'Your response can\'t be empty';
}

class PrescriptionValidator {
  final StringValidator inputValidator = NonEmptyStringValidator();
}

class PhoneNumberStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length >= 15;
  }
}

class SMSCodeStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length >= 6;
  }
}

class PhoneValidators {
  final StringValidator phoneNumberEmptyValidator = NonEmptyStringValidator();
  final StringValidator codeEmptyValidator = NonEmptyStringValidator();
  final StringValidator phoneNumberLengthValidator =
      PhoneNumberStringValidator();
  final StringValidator codeLengthValidator = SMSCodeStringValidator();
  final String emptyPhoneNumberErrorText = 'Your phone number can\'t be empty';
  final String emptyCodeErrorText = 'Your verification code can\'t be empty';
  final String phoneNumberLengthErrorText = 'This phone number is invalid!';
  final String codeLengthErrorText = 'This verification code is invalid!';
}
