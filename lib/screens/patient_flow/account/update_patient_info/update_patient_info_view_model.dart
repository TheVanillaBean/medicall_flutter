import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/screens/patient_flow/account/update_patient_info/update_patient_info_form.dart';
import 'package:Medicall/screens/patient_flow/registration/registration_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';

class UpdatePatientInfoViewModel
    with
        PhoneValidators,
        AddressValidators,
        CityValidators,
        StateValidators,
        ZipCodeValidators,
        ChangeNotifier {
  final AuthBase auth;
  final FirestoreDatabase firestoreDatabase;
  final UserProvider userProvider;

  @required
  PatientProfileInputType patientProfileInputType;

  String phoneNumber;
  String billingAddress;
  String billingAddressLine2;
  String mailingCity;
  String mailingState;
  String mailingZipCode;

  bool isLoading;
  bool submitted;
  PersonalFormStatus personalFormStatus;
  VerificationStatus verificationStatus;

  ScrollController viewController = ScrollController();
  ScrollController scrollController = ScrollController();

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

  UpdatePatientInfoViewModel({
    @required this.auth,
    @required this.firestoreDatabase,
    @required this.userProvider,
    this.patientProfileInputType = PatientProfileInputType.PHONE,
    this.phoneNumber = '',
    this.billingAddress = '',
    this.billingAddressLine2 = '',
    this.mailingCity = '',
    this.mailingState = '',
    this.mailingZipCode = '',
    this.isLoading = false,
    this.submitted = false,
  });

  void setVerificationStatus(VerificationStatus verificationStatus) {
    this.verificationStatus = verificationStatus;
  }

  ///Set initial values
  void initAddress() {
    this.billingAddress = userProvider.user.mailingAddress;
    this.billingAddressLine2 = userProvider.user.mailingAddressLine2;
    this.mailingCity = userProvider.user.mailingCity;
    this.mailingState = userProvider.user.mailingState;
    this.mailingZipCode = userProvider.user.mailingZipCode;
  }

  void initPhoneNumber() {
    this.phoneNumber = userProvider.user.phoneNumber;
  }

  bool get canSubmit {
    if (this.patientProfileInputType == PatientProfileInputType.PHONE) {
      return phoneNumberLengthValidator.isValid(phoneNumber) && submitted;
    } else if (this.patientProfileInputType ==
        PatientProfileInputType.ADDRESS) {
      return mailingAddressValidator.isValid(billingAddress) &&
          cityValidator.isValid(mailingCity) &&
          stateValidator.isValid(mailingState) &&
          zipCodeValidator.isValid(mailingZipCode) &&
          submitted;
    }
    return false;
  }

  String get phoneNumberErrorText {
    bool showErrorText =
        submitted && !phoneNumberLengthValidator.isValid(phoneNumber);
    return showErrorText ? phoneErrorText : null;
  }

  String get patientBillingAddressErrorText {
    bool showErrorText =
        submitted && !billingAddressValidator.isValid(billingAddress);
    return showErrorText ? billingAddressErrorText : null;
  }

  String get patientCityErrorText {
    bool showErrorText = submitted && !cityValidator.isValid(mailingCity);
    return showErrorText ? cityErrorText : null;
  }

  String get patientStateErrorText {
    bool showErrorText = submitted && !stateValidator.isValid(mailingState);
    return showErrorText ? stateErrorText : null;
  }

  String get patientZipCodeErrorText {
    bool showErrorText = submitted && !zipCodeValidator.isValid(mailingZipCode);
    return showErrorText ? zipCodeErrorText : null;
  }

  void updatePhoneNumber(String phoneNumber) =>
      updateWith(phoneNumber: phoneNumber);
  void updateBillingAddress(String billingAddress) =>
      updateWith(billingAddress: billingAddress);
  void updateBillingAddressLine2(String billingAddressLine2) =>
      updateWith(billingAddressLine2: billingAddressLine2);
  void updateMailingCity(String mailingCity) =>
      updateWith(mailingCity: mailingCity);
  void updateMailingState(String mailingState) =>
      updateWith(mailingState: mailingState);
  void updateMailingZipCode(String mailingZipCode) =>
      updateWith(mailingZipCode: mailingZipCode);

  Future<void> submit() async {
    updateWith(submitted: true);
    if (!this.canSubmit) {
      throw "Please correct the errors below...";
    }

    PatientUser medicallUser = userProvider.user;
    if (this.patientProfileInputType == PatientProfileInputType.PHONE) {
      medicallUser.phoneNumber = this.phoneNumber;
    } else if (this.patientProfileInputType ==
        PatientProfileInputType.ADDRESS) {
      medicallUser.mailingAddress = this.billingAddress;
      medicallUser.mailingAddressLine2 = this.billingAddressLine2;
      medicallUser.mailingCity = this.mailingCity;
      medicallUser.mailingState = this.mailingState;
      medicallUser.mailingZipCode = this.mailingZipCode;
    }
    await updateUserDetails(medicallUser);

    updateWith(submitted: false);
  }

  Future<void> updateUserDetails(PatientUser user) async {
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }

  void updateWith({
    String phoneNumber,
    String billingAddress,
    String billingAddressLine2,
    String mailingCity,
    String mailingState,
    String mailingZipCode,
    bool isLoading,
    bool submitted,
    bool checkValue,
  }) {
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.billingAddress = billingAddress ?? this.billingAddress;
    this.billingAddressLine2 = billingAddressLine2 ?? this.billingAddressLine2;
    this.mailingCity = mailingCity ?? this.mailingCity;
    this.mailingState = mailingState ?? this.mailingState;
    this.mailingZipCode = mailingZipCode ?? this.mailingZipCode;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
