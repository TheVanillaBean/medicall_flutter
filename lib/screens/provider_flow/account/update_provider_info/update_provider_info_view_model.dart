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
    @required this.firestoreDatabase,
    @required this.userProvider,
    this.profileInputType = ProfileInputType.PHONE,
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
      return mobilePhoneValidator.isValid(phoneNumber) && submitted;
    } else if (this.profileInputType == ProfileInputType.ADDRESS) {
      return mailingAddressValidator.isValid(mailingAddress) &&
          cityValidator.isValid(mailingCity) &&
          stateValidator.isValid(mailingState) &&
          zipCodeValidator.isValid(mailingZipCode) &&
          submitted;
    } else if (this.profileInputType == ProfileInputType.PROFESSIONAL_TITLE) {
      return professionalTitleValidator.isValid(professionalTitle) && submitted;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_LICENSE) {
      return medicalLicenseValidator.isValid(medLicense) && submitted;
    } else if (this.profileInputType ==
        ProfileInputType.MEDICAL_LICENSE_STATE) {
      return medicalLicenseStateValidator.isValid(medLicenseState) && submitted;
    } else if (this.profileInputType == ProfileInputType.NPI) {
      return npiValidator.isValid(npi) && submitted;
    } else if (this.profileInputType == ProfileInputType.BOARD_CERTIFIED) {
      return boardCertificationValidator.isValid(boardCertified) && submitted;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_SCHOOL) {
      return medicalSchoolValidator.isValid(medSchool) && submitted;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_RESIDENCY) {
      return medicalResidencyValidator.isValid(medResidency) && submitted;
    } else if (this.profileInputType == ProfileInputType.BIO) {
      return providerBioValidator.isValid(providerBio) && submitted;
    }
    return false;
  }

  Future<void> submit() async {
    updateWith(submitted: true);
    if (!this.canSubmit) {
      throw "Please correct the errors below...";
    }
    ProviderUser user = userProvider.user;
    if (this.profileInputType == ProfileInputType.PHONE) {
      user.phoneNumber = this.phoneNumber;
    } else if (this.profileInputType == ProfileInputType.ADDRESS) {
      user.mailingAddress = this.mailingAddress;
      user.mailingAddressLine2 = this.mailingAddressLine2;
      user.mailingCity = this.mailingCity;
      user.mailingState = this.mailingState;
      user.mailingZipCode = this.mailingZipCode;
    } else if (this.profileInputType == ProfileInputType.PROFESSIONAL_TITLE) {
      user.professionalTitle = this.professionalTitle;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_LICENSE) {
      user.medLicense = this.medLicense;
    } else if (this.profileInputType ==
        ProfileInputType.MEDICAL_LICENSE_STATE) {
      user.medLicenseState = this.medLicenseState;
    } else if (this.profileInputType == ProfileInputType.NPI) {
      user.npi = this.npi;
    } else if (this.profileInputType == ProfileInputType.BOARD_CERTIFIED) {
      user.boardCertified = this.boardCertified;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_SCHOOL) {
      user.medSchool = this.medSchool;
    } else if (this.profileInputType == ProfileInputType.MEDICAL_RESIDENCY) {
      user.medResidency = this.medResidency;
    } else if (this.profileInputType == ProfileInputType.BIO) {
      user.providerBio = this.providerBio;
    }

    await updateUserDetails(user);

    updateWith(submitted: false);
  }

  Future<void> updateUserDetails(ProviderUser user) async {
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }
}
