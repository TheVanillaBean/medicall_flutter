import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class ProviderRegistrationViewModel extends ProviderProfileViewModelBase {
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

  bool checkValue;
  bool isLoading;
  bool submitted;

  List<String> selectInsurances = [
    'Aetna',
    'AllWays Health Plan',
    'Blue Cross and Blue Shield of Massachusetts',
    'Cigna',
    'Fallon Community Health Plan',
    'Harvard Pilgrim Health Care',
    'Health Plans Inc.',
    'Humana',
    'Medicare',
    'Tufts Health Plan',
    'UnitedHealthcare',
    'AARP Medicare Replacement',
  ];

  List<String> acceptedInsurances = [];

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
    this.checkValue = false,
    this.isLoading = false,
    this.submitted = false,
  });

  bool get canSubmit {
    return emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        password == confirmPassword &&
        firstNameValidator.isValid(firstName) &&
        lastNameValidator.isValid(lastName) &&
        dobValidator.isValid(dob) &&
        mobilePhoneValidator.isValid(phoneNumber) &&
        practiceAddressValidator.isValid(mailingAddress) &&
        cityValidator.isValid(mailingCity) &&
        zipCodeValidator.isValid(mailingZipCode) &&
        professionalTitleValidator.isValid(professionalTitle) &&
        acceptedInsurances.length > 0 &&
        !isLoading;
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
        tempUserProvider.user.mailingAddress = this.mailingAddress;
        tempUserProvider.user.mailingAddressLine2 = this.mailingAddressLine2;
        tempUserProvider.user.mailingCity = this.mailingCity;
        tempUserProvider.user.mailingState = this.mailingState;
        tempUserProvider.user.mailingZipCode = this.mailingZipCode;
        (tempUserProvider.user as ProviderUser).professionalTitle =
            this.professionalTitle;
        (tempUserProvider.user as ProviderUser).medLicense = this.medLicense;
        (tempUserProvider.user as ProviderUser).medLicenseState =
            this.medLicenseState;
        (tempUserProvider.user as ProviderUser).npi = this.npi;
        (tempUserProvider.user as ProviderUser).boardCertified =
            this.boardCertified;
        (tempUserProvider.user as ProviderUser).selectedServices = [
          "Rash",
          "Hairloss",
          "Rosacea",
          "Acne",
          "Skin spots",
          "Cosmetic skin issues"
        ];
        (tempUserProvider.user as ProviderUser).acceptedInsurances =
            this.acceptedInsurances;

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
}
