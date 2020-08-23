import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/screens/PhoneAuth/phone_auth_state_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PersonalInfoViewModel
    with
        FirstNameValidators,
        LastNameValidators,
        PhoneValidators,
        DobValidators,
        AddressValidators,
        CityValidators,
        StateValidators,
        ZipCodeValidators,
        ChangeNotifier {
  String firstName;
  String lastName;
  String phoneNumber;
  DateTime birthDate = DateTime.now();
  String billingAddress;
  String city;
  String state;
  String zipCode;

  List<Asset> profileImage;

  bool isLoading;
  bool submitted;
  bool checkValue;
  PersonalFormStatus personalFormStatus;

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
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.birthDate,
    this.billingAddress = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.isLoading = false,
    this.submitted = false,
    this.checkValue,
    this.profileImage = const [],
  });

  bool get canSubmit {
    return firstNameValidator.isValid(firstName) &&
        lastNameValidator.isValid(lastName) &&
        phoneNumberEmptyValidator.isValid(phoneNumber) &&
        billingAddressValidator.isValid(billingAddress) &&
        cityValidator.isValid(city) &&
        stateValidator.isValid(state) &&
        zipCodeValidator.isValid(zipCode) &&
        dobValidator.isValid(birthDate) &&
        this.profileImage.length > 0 &&
        !isLoading;
  }

  String get birthday {
    final f = new DateFormat('MMMM-dd-yyyy');
    return this.birthDate.year <= DateTime.now().year - 18
        ? "${f.format(this.birthDate)}"
        : "Please Select";
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

  String get patientDobErrorText {
    bool showErrorText = this.submitted && !dobValidator.isValid(birthDate);
    return showErrorText ? dobErrorText : null;
  }

  void updateFirstName(String firstName) => updateWith(firstName: firstName);
  void updateLastName(String lastName) => updateWith(lastName: lastName);
  void updatePhoneNumber(String phoneNumber) =>
      updateWith(phoneNumber: phoneNumber);
  void updateBirthDate(DateTime birthDate) => updateWith(birthDate: birthDate);
  void updateBillingAddress(String billingAddress) =>
      updateWith(billingAddress: billingAddress);
  void updateCity(String city) => updateWith(city: city);
  void updateState(String state) => updateWith(state: state);
  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);
  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);

  DateTime get initialDatePickerDate {
    final DateTime currentDate = DateTime.now();

    this.birthDate = this.birthDate == null ? currentDate : this.birthDate;

    return this.birthDate.year <= DateTime.now().year - 18
        ? this.birthDate
        : DateTime(
            currentDate.year - 18,
            currentDate.month,
            currentDate.day,
          );
  }

  Future<void> submit() async {
    updateWith(submitted: true);

    if (this.profileImage.length == 0) {
      btnController.reset();
      throw "Please add a profile image...";
    }

    if (!canSubmit) {
      btnController.reset();
      throw "Please correct the errors...";
    }

    updateWith(isLoading: true);
    PatientUser medicallUser = userProvider.user;
    medicallUser.firstName = this.firstName;
    medicallUser.lastName = this.lastName;
    medicallUser.phoneNumber = this.phoneNumber;
    medicallUser.mailingAddress = this.billingAddress;
    medicallUser.dob = this.birthday;
    medicallUser.mailingState = this.state;
    medicallUser.mailingCity = this.city;
    medicallUser.mailingZipCode = this.zipCode;

    try {
      medicallUser.profilePic = await firebaseStorageService.uploadProfileImage(
          asset: this.profileImage.first);
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
    String firstName,
    String lastName,
    String phoneNumber,
    DateTime birthDate,
    String billingAddress,
    String city,
    String state,
    String zipCode,
    bool isLoading,
    bool submitted,
    bool checkValue,
    List<Asset> profileImage,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.birthDate = birthDate ?? this.birthDate;
    this.billingAddress = billingAddress ?? this.billingAddress;
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.profileImage = profileImage ?? this.profileImage;
    notifyListeners();
  }
}
