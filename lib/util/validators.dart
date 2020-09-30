import 'package:Medicall/util/string_utils.dart';

abstract class StringValidator {
  bool isValid(String value);
}

abstract class DateTimeValidator {
  bool isValid(DateTime value);
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

class BoardCertificationValidator implements StringValidator {
  List<String> boardCertification = [
    "Yes",
    "No",
    "Board Eligible",
  ];
  @override
  bool isValid(String value) {
    return boardCertification.contains(value);
  }
}

class ProfessionalTitleValidator implements StringValidator {
  List<String> professionalTitles = [
    "MD",
    "DO",
    "NP",
    "PA",
    "DMD",
    "DDS",
    "LCP",
    "PT",
  ];
  @override
  bool isValid(String value) {
    return professionalTitles.contains(value);
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
    "WY",
  ];
  @override
  bool isValid(String value) {
    return states.contains(value);
  }
}

class ShippingAddressValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length > 0;
  }
}

class ZipCodeValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length == 5;
  }
}

class DobValidator implements DateTimeValidator {
  @override
  bool isValid(DateTime dob) {
    return dob != null &&
        dob.isBefore(new DateTime.now().subtract(Duration(days: 18 * 365)));
  }
}

class FirstNameValidators {
  final StringValidator firstNameValidator = NonEmptyStringValidator();
  final String fNameErrorText = 'Please enter your first name';
}

class LastNameValidators {
  final StringValidator lastNameValidator = NonEmptyStringValidator();
  final String lNameErrorText = 'Please enter your last name';
}

class PersonalInfoValidators {
  final StringValidator inputValidator = NonEmptyStringValidator();
  final String invalidPersonalInfoErrorText = 'Your response can\'t be empty';
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = EmailValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final String invalidEmailErrorText = 'Please enter a valid email';
  final String invalidPasswordErrorText = 'Password can\'t be empty';
  final String invalidConfirmPasswordErrorText = 'Passwords do not match';
}

class DobValidators {
  final DateTimeValidator dobValidator = DobValidator();
  final String dobErrorText = 'Please enter a valid birth date (must be 18+)';
}

class MobilePhoneValidators {
  final StringValidator mobilePhoneValidator = NonEmptyStringValidator();
  final String mPhoneErrorText = 'Please enter a valid mobile phone number';
}

class PhoneValidators {
  final StringValidator phoneNumberEmptyValidator = NonEmptyStringValidator();
  final StringValidator codeEmptyValidator = NonEmptyStringValidator();
  final StringValidator phoneNumberLengthValidator =
      PhoneNumberStringValidator();
  final StringValidator codeLengthValidator = SMSCodeStringValidator();
  final String phoneErrorText = 'Please enter a valid phone number';
  final String emptyPhoneNumberErrorText = 'Your phone number can\'t be empty';
  final String emptyCodeErrorText = 'Your verification code can\'t be empty';
  final String phoneNumberLengthErrorText = 'This phone number is invalid!';
  final String codeLengthErrorText = 'This verification code is invalid!';
}

class AddressValidators {
  final StringValidator practiceAddressValidator = NonEmptyStringValidator();
  final StringValidator mailingAddressValidator = NonEmptyStringValidator();
  final StringValidator billingAddressValidator = NonEmptyStringValidator();
  final String addressErrorText = 'Please enter a valid street address';
  final String mailingAddressErrorText = 'Please enter a valid mailing address';
  final String billingAddressErrorText = 'Please enter a valid billing address';
}

class CityValidators {
  final StringValidator cityValidator = NonEmptyStringValidator();
  final String cityErrorText = 'Please enter a valid city';
}

class StateValidators {
  final StringValidator stateValidator = StateValidator();
  final String stateErrorText = 'Please select your state';
}

class ZipCodeValidators {
  final StringValidator zipCodeValidator = ZipCodeValidator();
  final String zipCodeErrorText = 'Please enter a valid zip code';
}

class ProfessionalTitleValidators {
  final StringValidator professionalTitleValidator =
      ProfessionalTitleValidator();
  final String profTitleErrorText = 'Please select your professional title';
}

class NpiValidators {
  final StringValidator npiValidator = NonEmptyStringValidator();
  final String npiErrorText = 'Please enter your NPI number';
}

class MedicalLicenseValidators {
  final StringValidator medicalLicenseValidator = NonEmptyStringValidator();
  final String medLicenseErrorText = 'Please enter your medical license number';
}

class MedicalLicenseStateValidators {
  final StringValidator medicalLicenseStateValidator = StateValidator();
  final String medicalLicenseStateErrorText =
      'Please select your medical license state';
}

class MedicalSchoolValidators {
  final StringValidator medicalSchoolValidator = NonEmptyStringValidator();
  final String medSchoolErrorText = 'Please enter your medical school';
}

class MedicalResidencyValidators {
  final StringValidator medicalResidencyValidator = NonEmptyStringValidator();
  final String medResidencyErrorText = 'Please enter your medical residency';
}

class BoardCertificationValidators {
  final StringValidator boardCertificationValidator =
      BoardCertificationValidator();
  final String boardCertifiedErrorText =
      'Please select your Board Certification status';
}

class ProviderBioValidators {
  final StringValidator providerBioValidator = NonEmptyStringValidator();
  final String bioErrorText = 'Please enter your bio';
}

class OptionInputValidator {
  final StringValidator inputValidator = NonEmptyStringValidator();
  final String invalidInputErrorText = 'Your response can\'t be empty';
}

class PrescriptionValidator {
  final StringValidator inputValidator = NonEmptyStringValidator();
}

class PrescriptionCheckoutValidator {
  final StringValidator shippingAddressValidator = ShippingAddressValidator();
  final StringValidator cityValidator = NonEmptyStringValidator();
  final StringValidator stateValidator = StateValidator();
  final StringValidator zipCodeValidator = ZipCodeValidator();
  final String shippingAddressErrorText = 'Invalid Shipping Address';
  final String cityErrorText = 'Invalid City';
  final String stateErrorText =
      'Please enter a valid two letter state abbreviation code';
  final String zipCodeErrorText = 'Invalid Zip Code';
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
