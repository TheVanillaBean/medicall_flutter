import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_form.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class UpdateProviderInfoViewModel extends ProviderProfileViewModelBase {
  final AuthBase auth;
  @required
  ProfileInputType profileInputType;

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

  UpdateProviderInfoViewModel({
    @required this.auth,
    @required this.profileInputType,
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

  bool get canSubmit {
    if (this.profileInputType == ProfileInputType.MEDICAL_RESIDENCY) {
      return medicalResidencyValidator.isValid(medResidency) && !isLoading;
    } else if (this.profileInputType == ProfileInputType.PHONE) {
      return mobilePhoneValidator.isValid(phoneNumber) && !isLoading;
    }
    return false;
  }

  Future<void> submit() async {
    updateWith(submitted: true);
    if (!this.canSubmit) {
      throw "Please correct the errors below...";
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
