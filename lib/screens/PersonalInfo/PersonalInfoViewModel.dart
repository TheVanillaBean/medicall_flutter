import 'package:Medicall/models/consult_model.dart';
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

  PersonalInfoViewModel({
    @required this.consult,
    @required this.userProvider,
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
        !isLoading;
  }

  String get birthday {
    final f = new DateFormat('yyyy-MM-dd');
    return this.birthDate.year <= DateTime.now().year - 18
        ? "Birthday: ${f.format(this.birthDate)}"
        : "Select Birthday";
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
    try {} catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
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
