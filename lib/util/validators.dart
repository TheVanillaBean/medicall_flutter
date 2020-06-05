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

class EmailAndPasswordValidators {
  final StringValidator emailValidator = EmailValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final String invalidEmailErrorText = 'Incorrect email format';
  final String invalidPasswordErrorText = 'Password can\'t be empty';
  final String invalidConfirmPasswordErrorText = 'Passwords do not match';
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
