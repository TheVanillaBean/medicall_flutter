import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/screens/provider_flow/account/update_provider_info/update_provider_info_form.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_profile_view_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';

class UpdateProviderInfoViewModel extends ProviderProfileViewModelBase {
  final AuthBase auth;
  final FirestoreDatabase firestoreDatabase;
  final UserProvider userProvider;

  @required
  ProfileInputType profileInputType;

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

  UpdateProviderInfoViewModel({
    @required this.auth,
    @required this.profileInputType,
    @required this.firestoreDatabase,
    @required this.userProvider,
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
    if (this.profileInputType == ProfileInputType.PHONE) {
      return mobilePhoneValidator.isValid(phoneNumber) && !isLoading;
    } else if (this.profileInputType == ProfileInputType.ADDRESS) {
      return mailingAddressValidator.isValid(mailingAddress) &&
          cityValidator.isValid(mailingCity) &&
          stateValidator.isValid(mailingState) &&
          zipCodeValidator.isValid(mailingZipCode) &&
          !isLoading;
    } else if (this.profileInputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return professionalTitleValidator.isValid(professionalTitle) &&
          !isLoading;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_LICENSE) {
      return medicalLicenseValidator.isValid(medLicense) && !isLoading;
    } else if (this.profileInputType ==
        ProfileInputType.MEDICAL_LICENSE_STATE) {
      return medicalLicenseStateValidator.isValid(medLicenseState) &&
          !isLoading;
    } else if (this.profileInputType == ProfileInputType.NPI) {
      return npiValidator.isValid(npi) && !isLoading;
    } else if (this.profileInputType == ProfileInputType.BOARD_CERTIFIED) {
      return boardCertificationValidator.isValid(boardCertified) && !isLoading;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_SCHOOL) {
      return medicalSchoolValidator.isValid(medSchool) && !isLoading;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_RESIDENCY) {
      return medicalResidencyValidator.isValid(medResidency) && !isLoading;
    } else if (this.profileInputType == ProfileInputType.BIO) {
      return providerBioValidator.isValid(providerBio) && !isLoading;
    }
    return false;
  }

  Future<void> submit() async {
    updateWith(submitted: true);
    if (!this.canSubmit) {
      throw "Please correct the errors below...";
    }
    ProviderUser user = userProvider.user;
    //set user uid
    if (this.profileInputType == ProfileInputType.PHONE) {
      user.phoneNumber = this.phoneNumber;
    } else if (this.profileInputType == ProfileInputType.ADDRESS) {
      user.mailingAddress = this.mailingAddress;
      user.mailingAddressLine2 = this.mailingAddressLine2;
      user.mailingCity = this.mailingCity;
      user.mailingState = this.mailingState;
      user.mailingZipCode = this.mailingZipCode;
    }

    await updateUserDetails(user);
  }

  Future<void> updateUserDetails(ProviderUser user) async {
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }
}
