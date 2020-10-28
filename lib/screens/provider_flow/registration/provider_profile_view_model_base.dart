import 'package:Medicall/screens/Shared/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Shared/Login/google_auth_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

abstract class ProviderProfileViewModelBase
    with
        FirstNameValidators,
        LastNameValidators,
        EmailAndPasswordValidators,
        DobValidators,
        MobilePhoneValidators,
        AddressValidators,
        CityValidators,
        StateValidators,
        ZipCodeValidators,
        ProfessionalTitleValidators,
        NpiValidators,
        MedicalLicenseValidators,
        MedicalLicenseStateValidators,
        MedicalSchoolValidators,
        MedicalResidencyValidators,
        BoardCertificationValidators,
        ProviderBioValidators,
        PracticeNameValidators,
        OptionInputValidator,
        ChangeNotifier {
  String email;
  String password;
  String confirmPassword;
  String firstName;
  String lastName;
  String phoneNumber;
  DateTime dob = DateTime.now();
  String mailingAddress;
  String mailingAddressLine2;
  String mailingCity;
  String mailingState;
  String mailingZipCode;
  String professionalTitle;
  String medLicense;
  String medLicenseState;
  String medSchool;
  String medResidency;
  String npi;
  String boardCertified;
  String providerBio;
  String practiceName;
  String input;

  bool checkValue;
  bool isLoading;
  bool submitted;
  GoogleAuthModel googleAuthModel;
  AppleSignInModel appleSignInModel;
  VerificationStatus verificationStatus;

  ScrollController viewController = ScrollController();
  ScrollController scrollController = ScrollController();

  final List<String> boardCertification = const <String>[
    "Yes",
    "No",
    "Board Eligible"
  ];

  final List<String> professionalTitles = const <String>[
    "MD",
    "DO",
    "NP",
    "PA",
    "DMD",
    "DDS",
    "LCP",
    "PT"
  ];

  final List<String> states = const <String>[
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

  ProviderProfileViewModelBase({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.dob,
    this.mailingAddress = '',
    this.mailingAddressLine2 = '',
    this.mailingCity = '',
    this.mailingState = '',
    this.mailingZipCode = '',
    this.professionalTitle = '',
    this.medLicense = '',
    this.medLicenseState = '',
    this.medSchool = '',
    this.medResidency = '',
    this.npi = '',
    this.boardCertified = '',
    this.providerBio = '',
    this.practiceName = '',
    this.checkValue = false,
    this.isLoading = false,
    this.submitted = false,
  });

  void setVerificationStatus(VerificationStatus verificationStatus) {
    this.verificationStatus = verificationStatus;
  }

  String get firstNameErrorText {
    bool showErrorText =
        this.submitted && !firstNameValidator.isValid(firstName);
    return showErrorText ? fNameErrorText : null;
  }

  String get lastNameErrorText {
    bool showErrorText = this.submitted && !lastNameValidator.isValid(lastName);
    return showErrorText ? lNameErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = this.submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  String get providerDobErrorText {
    bool showErrorText = this.submitted && !dobValidator.isValid(dob);
    return showErrorText ? dobErrorText : null;
  }

  String get mobilePhoneErrorText {
    bool showErrorText =
        this.submitted && !mobilePhoneValidator.isValid(phoneNumber);
    return showErrorText ? mPhoneErrorText : null;
  }

  String get passwordErrorText {
    bool showErrorText = this.submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String get confirmPasswordErrorText {
    bool showErrorText = this.submitted && confirmPassword != password;
    return showErrorText ? invalidConfirmPasswordErrorText : null;
  }

  String get practiceAddressErrorText {
    bool showErrorText =
        this.submitted && !practiceAddressValidator.isValid(mailingAddress);
    return showErrorText ? addressErrorText : null;
  }

  String get practiceCityErrorText {
    bool showErrorText = this.submitted && !cityValidator.isValid(mailingCity);
    return showErrorText ? cityErrorText : null;
  }

  String get practiceStateErrorText {
    bool showErrorText =
        this.submitted && !stateValidator.isValid(mailingState);
    return showErrorText ? stateErrorText : null;
  }

  String get practiceZipCodeErrorText {
    bool showErrorText =
        this.submitted && !zipCodeValidator.isValid(mailingZipCode);
    return showErrorText ? zipCodeErrorText : null;
  }

  String get professionalTitleErrorText {
    bool showErrorText = this.submitted &&
        !professionalTitleValidator.isValid(professionalTitle);
    return showErrorText ? profTitleErrorText : null;
  }

  String get npiNumberErrorText {
    bool showErrorText = this.submitted && !npiValidator.isValid(npi);
    return showErrorText ? npiErrorText : null;
  }

  String get medicalLicenseErrorText {
    bool showErrorText =
        this.submitted && !medicalLicenseValidator.isValid(medLicense);
    return showErrorText ? medLicenseErrorText : null;
  }

  String get medicalStateErrorText {
    bool showErrorText = this.submitted &&
        !medicalLicenseStateValidator.isValid(medLicenseState);
    return showErrorText ? medicalLicenseStateErrorText : null;
  }

  String get medicalSchoolErrorText {
    bool showErrorText =
        this.submitted && !medicalSchoolValidator.isValid(medSchool);
    return showErrorText ? medSchoolErrorText : null;
  }

  String get invalidOptionInputErrorText {
    bool showErrorText = this.submitted && !inputValidator.isValid(input);
    return showErrorText ? invalidInputErrorText : null;
  }

  String get medicalResidencyErrorText {
    bool showErrorText =
        this.submitted && !medicalResidencyValidator.isValid(medResidency);
    return showErrorText ? medResidencyErrorText : null;
  }

  String get boardCertificationErrorText {
    bool showErrorText =
        this.submitted && !boardCertificationValidator.isValid(boardCertified);
    return showErrorText ? boardCertifiedErrorText : null;
  }

  String get providerBioErrorText {
    bool showErrorText =
        this.submitted && !providerBioValidator.isValid(providerBio);
    return showErrorText ? bioErrorText : null;
  }

  String get providerPracticeNameErrorText {
    bool showErrorText =
        this.submitted && !practiceNameValidator.isValid(practiceName);
    return showErrorText ? providerPracticeNameErrorText : null;
  }

  String get birthday {
    final f = new DateFormat('MM/dd/yyyy');
    return this.dob.year <= DateTime.now().year - 18
        ? "${f.format(this.dob)}"
        : "Please Select";
  }

  void updateEmail(String email) => updateWith(email: email);
  void updatePassword(String password) => updateWith(password: password);
  void updateConfirmPassword(String password) =>
      updateWith(confirmPassword: password);
  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);
  void updateFirstName(String fName) => updateWith(firstName: fName);
  void updateLastName(String lName) => updateWith(lastName: lName);
  void updatePhoneNumber(String phoneNumber) =>
      updateWith(phoneNumber: phoneNumber);
  void updateDOB(DateTime dob) => updateWith(dob: dob);
  void updateMailingAddress(String mailingAddress) =>
      updateWith(mailingAddress: mailingAddress);
  void updateMailingAddressLine2(String mailingAddressLine2) =>
      updateWith(mailingAddressLine2: mailingAddressLine2);
  void updateMailingCity(String mailingCity) =>
      updateWith(mailingCity: mailingCity);
  void updateMailingState(String mailingState) =>
      updateWith(mailingState: mailingState);
  void updateMailingZipCode(String mailingZipCode) =>
      updateWith(mailingZipCode: mailingZipCode);
  void updateProfessionalTitle(String professionalTitle) =>
      updateWith(professionalTitle: professionalTitle);
  void updateMedLicense(String medLicense) =>
      updateWith(medLicense: medLicense);
  void updateMedLicenseState(String medLicenseState) =>
      updateWith(medLicenseState: medLicenseState);
  void updateNpi(String npi) => updateWith(npi: npi);
  void updateBoardCertified(String boardCertified) =>
      updateWith(boardCertified: boardCertified);
  void updateProviderBio(String providerBio) =>
      updateWith(providerBio: providerBio);
  void updatePracticeName(String practiceName) =>
      updateWith(practiceName: practiceName);
  void updateMedSchool(String medSchool) => updateWith(medSchool: medSchool);
  void updateMedResidency(String medResidency) =>
      updateWith(medResidency: medResidency);

  DateTime get initialDatePickerDate {
    final DateTime currentDate = DateTime.now();

    this.dob = this.dob == null ? currentDate : this.dob;

    return this.dob.year <= DateTime.now().year - 18
        ? this.dob
        : DateTime(
            currentDate.year - 18,
            currentDate.month,
            currentDate.day,
          );
  }

  Future<void> submit();

  void updateWith({
    String email,
    String password,
    String confirmPassword,
    String firstName,
    String lastName,
    String phoneNumber,
    DateTime dob,
    String mailingAddress,
    String mailingAddressLine2,
    String mailingCity,
    String mailingState,
    String mailingZipCode,
    String professionalTitle,
    String medLicense,
    String medLicenseState,
    String medSchool,
    String medResidency,
    String npi,
    String boardCertified,
    String providerBio,
    String practiceName,
    bool checkValue,
    bool isLoading,
    bool submitted,
    GoogleAuthModel googleAuthModel,
    AppleSignInModel appleSignInModel,
    List<Asset> profileImage,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.confirmPassword = confirmPassword ?? this.confirmPassword;
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.dob = dob ?? this.dob;
    this.mailingAddress = mailingAddress ?? this.mailingAddress;
    this.mailingAddressLine2 = mailingAddressLine2 ?? this.mailingAddressLine2;
    this.mailingCity = mailingCity ?? this.mailingCity;
    this.mailingState = mailingState ?? this.mailingState;
    this.mailingZipCode = mailingZipCode ?? this.mailingZipCode;
    this.professionalTitle = professionalTitle ?? this.professionalTitle;
    this.npi = npi ?? this.npi;
    this.boardCertified = boardCertified ?? this.boardCertified;
    this.providerBio = providerBio ?? this.providerBio;
    this.medLicense = medLicense ?? this.medLicense;
    this.medLicenseState = medLicenseState ?? this.medLicenseState;
    this.medSchool = medSchool ?? this.medSchool;
    this.medResidency = medResidency ?? this.medResidency;
    this.practiceName = practiceName ?? this.practiceName;
    this.checkValue = checkValue ?? this.checkValue;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.googleAuthModel = googleAuthModel ?? this.googleAuthModel;
    this.appleSignInModel = appleSignInModel ?? this.appleSignInModel;
    notifyListeners();
  }
}

mixin VerificationStatus {
  void updateStatus(String msg);
}
