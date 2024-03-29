import 'package:Medicall/common_widgets/camera_picker/constants/constants.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/screens/patient_flow/registration/registration_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

abstract class PersonalInfoVMProperties {
  static String get profilePhoto => 'profile_photo';
  static String get form => 'form';
}

class PersonalInfoViewModel extends PropertyChangeNotifier
    with
        PhoneValidators,
        AddressValidators,
        CityValidators,
        StateValidators,
        ZipCodeValidators {
  String phoneNumber;
  String billingAddress;
  String billingAddressLine2;
  String city;
  String state;
  String zipCode;

  AssetEntity profileImage;

  bool isLoading;
  bool submitted;
  bool checkValue;
  PersonalFormStatus personalFormStatus;
  VerificationStatus verificationStatus;

  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

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

  final Consult consult;
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;
  final FirebaseStorageService firebaseStorageService;

  PersonalInfoViewModel({
    @required this.consult,
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.firebaseStorageService,
    this.phoneNumber = '',
    this.billingAddress = '',
    this.billingAddressLine2 = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.isLoading = false,
    this.submitted = false,
    this.checkValue,
    this.profileImage,
  });

  void setVerificationStatus(VerificationStatus verificationStatus) {
    this.verificationStatus = verificationStatus;
  }

  bool get canSubmit {
    return phoneNumberEmptyValidator.isValid(phoneNumber) &&
        billingAddressValidator.isValid(billingAddress) &&
        cityValidator.isValid(city) &&
        stateValidator.isValid(state) &&
        zipCodeValidator.isValid(zipCode) &&
        this.profileImage != null &&
        !isLoading;
  }

  String get phoneNumberErrorText {
    bool showErrorText =
        submitted && !phoneNumberEmptyValidator.isValid(phoneNumber);
    return showErrorText ? phoneErrorText : null;
  }

  String get patientBillingAddressErrorText {
    bool showErrorText =
        submitted && !billingAddressValidator.isValid(billingAddress);
    return showErrorText ? billingAddressErrorText : null;
  }

  String get patientCityErrorText {
    bool showErrorText = submitted && !cityValidator.isValid(city);
    return showErrorText ? cityErrorText : null;
  }

  String get patientStateErrorText {
    bool showErrorText = submitted && !stateValidator.isValid(state);
    return showErrorText ? stateErrorText : null;
  }

  String get patientZipCodeErrorText {
    bool showErrorText = submitted && !zipCodeValidator.isValid(zipCode);
    return showErrorText ? zipCodeErrorText : null;
  }

  void updatePhoneNumber(String phoneNumber) =>
      updateWith(phoneNumber: phoneNumber);
  void updateBillingAddress(String billingAddress) =>
      updateWith(billingAddress: billingAddress);
  void updateBillingAddressLine2(String billingAddressLine2) =>
      updateWith(billingAddressLine2: billingAddressLine2);
  void updateCity(String city) => updateWith(city: city);
  void updateState(String state) => updateWith(state: state);
  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);
  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);

  Future<void> submit() async {
    updateWith(submitted: true);

    if (this.profileImage == null) {
      btnController.reset();
      throw "Please add a profile image...";
    }

    if (!canSubmit) {
      btnController.reset();
      throw "Please correct the errors...";
    }

    updateWith(isLoading: true);
    PatientUser medicallUser = userProvider.user;
    medicallUser.phoneNumber = this.phoneNumber;
    medicallUser.mailingAddress = this.billingAddress;
    medicallUser.mailingAddressLine2 = this.billingAddressLine2;
    medicallUser.mailingState = this.state;
    medicallUser.mailingCity = this.city;
    medicallUser.mailingZipCode = this.zipCode;

    try {
      medicallUser.profilePic = await firebaseStorageService.uploadProfileImage(
          asset: this.profileImage);
    } catch (e) {
      updateWith(submitted: false, isLoading: false);
      btnController.reset();
      throw "Could not save your profile picture!";
    }

    userProvider.user = medicallUser;
    await firestoreDatabase.setUser(userProvider.user);
    btnController.success();
    updateWith(submitted: false, isLoading: false);
  }

  void updateWith({
    String phoneNumber,
    String billingAddress,
    String billingAddressLine2,
    String city,
    String state,
    String zipCode,
    bool isLoading,
    bool submitted,
    bool checkValue,
    AssetEntity profileImage,
  }) {
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.billingAddress = billingAddress ?? this.billingAddress;
    this.billingAddressLine2 = billingAddressLine2 ?? this.billingAddressLine2;
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;

    notifyListeners(PersonalInfoVMProperties.form);

    this.profileImage = profileImage ?? this.profileImage;

    if (profileImage != null) {
      notifyListeners(PersonalInfoVMProperties.profilePhoto);
    }

    notifyListeners();
  }
}
