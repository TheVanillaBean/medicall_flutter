import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PersonalInfoViewModel with PersonalInfoValidator, ChangeNotifier {
  String firstName;
  String lastName;
  String billingAddress;
  String zipCode;
  DateTime birthDate = DateTime.now();
  List<Asset> profileImage;

  bool isLoading;
  bool submitted;

  final Consult consult;
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;

  PersonalInfoViewModel({
    @required this.consult,
    @required this.userProvider,
    @required this.firestoreDatabase,
    this.firstName = '',
    this.lastName = '',
    this.billingAddress = '',
    this.zipCode = '',
    this.isLoading = false,
    this.submitted = false,
    this.profileImage = const [],
  });

  bool get canSubmit {
    return inputValidator.isValid(firstName) &&
        inputValidator.isValid(lastName) &&
        inputValidator.isValid(billingAddress) &&
        inputValidator.isValid(zipCode) &&
        this.birthDate.year <= DateTime.now().year - 18 &&
        this.profileImage.length > 0 &&
        !isLoading;
  }

  String get birthday {
    final f = new DateFormat('yyyy-MM-dd');
    return this.birthDate.year <= DateTime.now().year - 18
        ? "${f.format(this.birthDate)}"
        : "Please Select";
  }

  String get firstNameErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(firstName);
    return showErrorText ? invalidPersonalInfoErrorText : null;
  }

  String get lastNameErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(lastName);
    return showErrorText ? invalidPersonalInfoErrorText : null;
  }

  String get billingAddressErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(billingAddress);
    return showErrorText ? invalidPersonalInfoErrorText : null;
  }

  String get zipCodeErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(zipCode);
    return showErrorText ? invalidPersonalInfoErrorText : null;
  }

  void updateFirstName(String firstName) => updateWith(firstName: firstName);
  void updateLastName(String lastName) => updateWith(lastName: lastName);
  void updateBillingAddress(String billingAddress) =>
      updateWith(billingAddress: billingAddress);
  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    MedicallUser medicallUser = userProvider.medicallUser;
    medicallUser.firstName = this.firstName;
    medicallUser.lastName = this.lastName;
    medicallUser.address = this.billingAddress;
    medicallUser.dob = this.birthday;
    userProvider.medicallUser = medicallUser;
    await firestoreDatabase.setUser(userProvider.medicallUser);
    updateWith(submitted: false, isLoading: false);
  }

  void updateWith({
    String firstName,
    String lastName,
    String billingAddress,
    String zipCode,
    DateTime birthDate,
    bool isLoading,
    bool submitted,
    List<Asset> profileImage,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.billingAddress = billingAddress ?? this.billingAddress;
    this.zipCode = zipCode ?? this.zipCode;
    this.birthDate = birthDate ?? this.birthDate;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.profileImage = profileImage ?? this.profileImage;
    notifyListeners();
  }
}
