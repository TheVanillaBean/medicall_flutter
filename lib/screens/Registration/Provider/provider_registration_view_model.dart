import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
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
    with EmailAndPasswordValidators, ProviderStateValidators, ChangeNotifier {
  final NonAuthDatabase nonAuthDatabase;
  final AuthBase auth;
  final TempUserProvider tempUserProvider;

  String email;
  String password;
  String confirmPassword;
  String firstName;
  String lastName;
  String phoneNumber;
  DateTime dob;
  String address;
  String city;
  String state;
  String zipCode;
  String titles;
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

  bool isAdult(String birthDateString) {
    String datePattern = "MM/dd/yyyy";

    // Current time - at this moment
    DateTime today = DateTime.now();

    // Parsed date to check
    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 18 years ahead
    DateTime adultDate = DateTime(
      birthDate.year + 18,
      birthDate.month,
      birthDate.day,
    );

    return adultDate.isBefore(today);
  }

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
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.titles = '',
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
        !isLoading;
  }

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String get confirmPasswordErrorText {
    bool showErrorText = submitted && confirmPassword != password;
    return showErrorText ? invalidConfirmPasswordErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  String get medStateErrorText {
    bool showErrorText = submitted && !stateValidator.isValid(medLicenseState);
    return showErrorText ? medStateErrorText : null;
  }

  String get birthday {
    final f = new DateFormat('MMMM-dd-yyyy');
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
  void updateCity(String city) => updateWith(city: city);
  void updateState(String state) => updateWith(state: state);
  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);
  void updateTitles(String titles) => updateWith(titles: titles);
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
//    if (!checkValue) {
//      this.verificationStatus.updateStatus(
//          "You have to agree to the Terms and Conditions, as well as the Privacy policy before signing in");
//      return;
//    }

//    if (password != confirmPassword) {
//      this.verificationStatus.updateStatus("Passwords do not match.");
//      return;
//    }

    try {
      updateWith(isLoading: true);
      bool emailAlreadyUsed = await auth.emailAlreadyUsed(email: this.email);
      if (!emailAlreadyUsed) {
        this.auth.triggerAuthStream = false;
//        this.verificationStatus.updateStatus(
//            'Saving User Details. This may take several seconds...');
        FirebaseUser user = await auth.createUserWithEmailAndPassword(
            email: this.email, password: this.password);
        tempUserProvider.setUser(userType: USER_TYPE.PROVIDER);
        tempUserProvider.user.uid = user.uid;
        tempUserProvider.user.email = this.email;
        tempUserProvider.user.firstName = this.firstName;
        tempUserProvider.user.lastName = this.lastName;
        tempUserProvider.user.phoneNumber = this.phoneNumber;
        tempUserProvider.user.dob = this.birthday;
        tempUserProvider.user.address = this.address;
        tempUserProvider.user.city = this.city;
        tempUserProvider.user.state = this.state;
        tempUserProvider.user.zipCode = this.zipCode;
        (tempUserProvider.user as ProviderUser).titles = this.titles;
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

  void saveUserDetails(FirebaseUser user) async {
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
    String city,
    String state,
    String zipCode,
    String titles,
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
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.titles = titles ?? this.titles;
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
