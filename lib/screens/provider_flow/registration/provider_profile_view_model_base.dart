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
        ChangeNotifier {
  final NonAuthDatabase nonAuthDatabase;
  final AuthBase auth;
  final TempUserProvider tempUserProvider;

  String email;
  String password;
  String confirmPassword;
  String firstName;
  String lastName;
  String phoneNumber;
  DateTime dob = DateTime.now();
  String address;
  String addressLine2;
  String city;
  String state;
  String zipCode;
  String professionalTitle;
  String medLicense;
  String medLicenseState;
  String medSchool;
  String medResidency;
  String npi;
  String boardCertified;
  String providerBio;

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
    @required this.nonAuthDatabase,
    @required this.auth,
    @required this.tempUserProvider,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.dob,
    this.address = '',
    this.addressLine2 = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.professionalTitle = '',
    this.medLicense = '',
    this.medLicenseState = '',
    this.medSchool = '',
    this.medResidency = '',
    this.npi = '',
    this.boardCertified = '',
    this.providerBio = '',
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
        this.submitted && !practiceAddressValidator.isValid(address);
    return showErrorText ? addressErrorText : null;
  }

  String get practiceCityErrorText {
    bool showErrorText = this.submitted && !cityValidator.isValid(city);
    return showErrorText ? cityErrorText : null;
  }

  String get practiceStateErrorText {
    bool showErrorText = this.submitted && !stateValidator.isValid(state);
    return showErrorText ? stateErrorText : null;
  }

  String get practiceZipCodeErrorText {
    bool showErrorText = this.submitted && !zipCodeValidator.isValid(zipCode);
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
  void updateAddress(String address) => updateWith(address: address);
  void updateAddressLine2(String addressLine2) =>
      updateWith(addressLine2: addressLine2);
  void updateCity(String city) => updateWith(city: city);
  void updateState(String state) => updateWith(state: state);
  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);
  void updateProfessionalTitle(String professionalTitle) =>
      updateWith(professionalTitle: professionalTitle);
  void updateMedLicense(String medLicense) =>
      updateWith(medLicense: medLicense);
  void updateMedLicenseState(String state) =>
      updateWith(medLicenseState: state);
  void updateNpi(String npi) => updateWith(npi: npi);
  void updateBoardCertified(String boardCertified) =>
      updateWith(boardCertified: boardCertified);
  void updateProviderBio(String providerBio) =>
      updateWith(providerBio: providerBio);
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
    String address,
    String addressLine2,
    String city,
    String state,
    String zipCode,
    String professionalTitle,
    String medLicense,
    String medLicenseState,
    String medSchool,
    String medResidency,
    String npi,
    String boardCertified,
    String providerBio,
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
    this.address = address ?? this.address;
    this.addressLine2 = addressLine2 ?? this.addressLine2;
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.professionalTitle = professionalTitle ?? this.professionalTitle;
    this.npi = npi ?? this.npi;
    this.boardCertified = boardCertified ?? this.boardCertified;
    this.providerBio = providerBio ?? this.providerBio;
    this.medLicense = medLicense ?? this.medLicense;
    this.medLicenseState = medLicenseState ?? this.medLicenseState;
    this.medSchool = medSchool ?? this.medSchool;
    this.medResidency = medResidency ?? this.medResidency;
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
