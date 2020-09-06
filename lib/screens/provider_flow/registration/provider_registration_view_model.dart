import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/Shared/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Shared/Login/google_auth_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ProviderRegistrationViewModel
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
        BoardCertificationValidators,
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
  String npi;
  String boardCertified;

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

  ProviderRegistrationViewModel({
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
    this.npi = '',
    this.boardCertified = '',
    this.checkValue = false,
    this.isLoading = false,
    this.submitted = false,
  });

  void setVerificationStatus(VerificationStatus verificationStatus) {
    this.verificationStatus = verificationStatus;
  }

  bool get canSubmit {
    return emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        password == confirmPassword &&
        firstNameValidator.isValid(firstName) &&
        lastNameValidator.isValid(lastName) &&
        dobValidator.isValid(dob) &&
        mobilePhoneValidator.isValid(phoneNumber) &&
        practiceAddressValidator.isValid(address) &&
        cityValidator.isValid(city) &&
        zipCodeValidator.isValid(zipCode) &&
        professionalTitleValidator.isValid(professionalTitle) &&
        !isLoading;
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

  String get boardCertificationErrorText {
    bool showErrorText =
        this.submitted && !boardCertificationValidator.isValid(boardCertified);
    return showErrorText ? boardCertifiedErrorText : null;
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

  Future<void> submit() async {
    updateWith(submitted: true);
    if (!this.canSubmit) {
      this
          .verificationStatus
          .updateStatus("Please correct the errors below...");
      return;
    }
    if (!checkValue) {
      this.verificationStatus.updateStatus(
          "You have to agree to the Terms and Conditions, as well as the Privacy policy before signing in");
      return;
    }

    if (password != confirmPassword) {
      this.verificationStatus.updateStatus("Passwords do not match.");
      return;
    }

    try {
      updateWith(isLoading: true);
      bool emailAlreadyUsed = await auth.emailAlreadyUsed(email: this.email);
      if (!emailAlreadyUsed) {
        this.auth.triggerAuthStream = false;
        this.verificationStatus.updateStatus(
            'Saving User Details. This may take several seconds...');
        User user = await auth.createUserWithEmailAndPassword(
            email: this.email, password: this.password);
        tempUserProvider.setUser(userType: USER_TYPE.PROVIDER);
        tempUserProvider.user.uid = user.uid;
        tempUserProvider.user.email = this.email;
        tempUserProvider.user.firstName = this.firstName;
        tempUserProvider.user.lastName = this.lastName;
        tempUserProvider.user.phoneNumber = this.phoneNumber;
        tempUserProvider.user.dob = this.birthday;
        tempUserProvider.user.mailingAddress = this.address;
        tempUserProvider.user.mailingAddressLine2 = this.addressLine2;
        tempUserProvider.user.mailingCity = this.city;
        tempUserProvider.user.mailingState = this.state;
        tempUserProvider.user.mailingZipCode = this.zipCode;
        (tempUserProvider.user as ProviderUser).professionalTitle =
            this.professionalTitle;
        (tempUserProvider.user as ProviderUser).medLicense = this.medLicense;
        (tempUserProvider.user as ProviderUser).medLicenseState =
            this.medLicenseState;
        (tempUserProvider.user as ProviderUser).npi = this.npi;
        (tempUserProvider.user as ProviderUser).boardCertified =
            this.boardCertified;
        updateWith(submitted: false, isLoading: false);
        saveUserDetails(user);
      } else {
        throw 'This email address is taken.';
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void saveUserDetails(User user) async {
    await this.addNewUserToFirestore();
    this.auth.addUserToAuthStream(user: user);
  }

  Future<void> addNewUserToFirestore() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String token = await _firebaseMessaging.getToken();
    tempUserProvider.user.devTokens = [token];
    await nonAuthDatabase.setUser(tempUserProvider.user);
  }

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
    String npi,
    String boardCertified,
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
    this.medLicense = medLicense ?? this.medLicense;
    this.medLicenseState = medLicenseState ?? this.medLicenseState;
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
