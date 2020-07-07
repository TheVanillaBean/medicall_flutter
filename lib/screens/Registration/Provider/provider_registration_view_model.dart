import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class ProviderRegistrationViewModel
    with EmailAndPasswordValidators, ChangeNotifier {
  final NonAuthDatabase nonAuthDatabase;
  final AuthBase auth;
  final TempUserProvider tempUserProvider;

  String email;
  String password;
  String confirmPassword;
  String firstName;
  String lastName;
  String dob;
  String address;
  String titles;
  String medLicense;
  String medLicenseState;

  bool checkValue;
  bool isLoading;
  bool submitted;
  GoogleAuthModel googleAuthModel;
  AppleSignInModel appleSignInModel;
  VerificationStatus verificationStatus;

  ProviderRegistrationViewModel({
    @required this.nonAuthDatabase,
    @required this.auth,
    @required this.tempUserProvider,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
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
    return showErrorText ? invalidEmailErrorText : "";
  }

  void updateEmail(String email) => updateWith(email: email);
  void updatePassword(String password) => updateWith(password: password);
  void updateConfirmPassword(String password) =>
      updateWith(confirmPassword: password);
  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);
  void updateFirstName(String fName) => updateWith(firstName: fName);
  void updateLastName(String lName) => updateWith(lastName: lName);
  void updateDOB(String dob) => updateWith(dob: dob);
  void updateAddress(String address) => updateWith(address: address);
  void updateTitles(String titles) => updateWith(titles: titles);
  void updateMedLicense(String medLicense) =>
      updateWith(medLicense: medLicense);
  void updateMedLicenseState(String state) =>
      updateWith(medLicenseState: state);

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
        tempUserProvider.user.dob = this.dob;
        tempUserProvider.user.address = this.address;
        (tempUserProvider.user as ProviderUser).titles = this.titles;
        (tempUserProvider.user as ProviderUser).medLicense = this.medLicense;
        (tempUserProvider.user as ProviderUser).medLicenseState =
            this.medLicenseState;
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
    String dob,
    String address,
    String titles,
    String medLicense,
    String medLicenseState,
    bool checkValue,
    bool isLoading,
    bool submitted,
    GoogleAuthModel googleAuthModel,
    AppleSignInModel appleSignInModel,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.confirmPassword = confirmPassword ?? this.confirmPassword;
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.dob = dob ?? this.dob;
    this.address = address ?? this.address;
    this.titles = titles ?? this.titles;
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
