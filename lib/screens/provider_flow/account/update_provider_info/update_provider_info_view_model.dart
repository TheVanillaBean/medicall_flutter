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
  String practiceName;

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
    this.practiceName = '',
    this.checkValue = false,
    this.isLoading = false,
    this.submitted = false,
  });

  ///Set initial values
  void initPracticeName() {
    this.practiceName = (userProvider.user as ProviderUser).practiceName;
  }

  void initAddress() {
    this.mailingAddress = userProvider.user.mailingAddress;
    this.mailingAddressLine2 = userProvider.user.mailingAddressLine2;
    this.mailingCity = userProvider.user.mailingCity;
    this.mailingState = userProvider.user.mailingState;
    this.mailingZipCode = userProvider.user.mailingZipCode;
  }

  void initPhoneNumber() {
    this.phoneNumber = userProvider.user.phoneNumber;
  }

  void initProfessionalTitle() {
    this.professionalTitle =
        (userProvider.user as ProviderUser).professionalTitle;
  }

  void initMedicalLicense() {
    this.medLicense = (userProvider.user as ProviderUser).medLicense;
  }

  void initMedicalLicenseState() {
    this.medLicenseState = (userProvider.user as ProviderUser).medLicenseState;
  }

  void initNpi() {
    this.npi = (userProvider.user as ProviderUser).npi;
  }

  void initBoardCertified() {
    this.boardCertified = (userProvider.user as ProviderUser).boardCertified;
  }

  void initMedicalSchool() {
    this.medSchool = (userProvider.user as ProviderUser).medSchool;
  }

  void initMedicalResidency() {
    this.medResidency = (userProvider.user as ProviderUser).medResidency;
  }

  void initProviderBio() {
    this.providerBio = (userProvider.user as ProviderUser).providerBio;
  }

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
    } else if (this.profileInputType == ProfileInputType.PRACTICE_NAME) {
      return practiceNameValidator.isValid(practiceName) && submitted;
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
    } else if (this.profileInputType == ProfileInputType.PRACTICE_NAME) {
      user.practiceName = this.practiceName;
    }

    await updateUserDetails(user);

    updateWith(submitted: false);
  }

  Future<void> updateUserDetails(ProviderUser user) async {
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }
}
