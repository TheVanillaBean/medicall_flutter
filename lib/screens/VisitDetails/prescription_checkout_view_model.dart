import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PrescriptionCheckoutViewModel
    with PrescriptionCheckoutValidator, ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;

  String consultId;
  List<TreatmentOptions> treatmentOptions = [];
  String shippingAddress;
  String city;
  String state;
  String zipCode;
  bool useAccountAddress;
  PaymentMethod selectedPaymentMethod;
  bool isLoading;

  PrescriptionCheckoutViewModel({
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.treatmentOptions,
    @required this.consultId,
    this.shippingAddress = "",
    this.city = "",
    this.state = "",
    this.zipCode = "",
    this.useAccountAddress = true,
    this.isLoading = false,
  });

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

  bool get canSubmit {
    return shippingAddressValidator.isValid(shippingAddress) &&
        cityValidator.isValid(city) &&
        stateValidator.isValid(state) &&
        !isLoading;
  }

  String get shippingAddressErrorText {
    bool showErrorText =
        !isLoading && !shippingAddressValidator.isValid(shippingAddress);
    return showErrorText ? shippingAddressErrorText : null;
  }

  String get zipCodeErrorText {
    bool showErrorText = !isLoading && !zipCodeValidator.isValid(zipCode);
    return showErrorText ? zipCodeErrorText : null;
  }

  void updateShippingAddress(String shippingAddress) =>
      updateWith(shippingAddress: shippingAddress);

  void updateCity(String city) => updateWith(city: city);

  void updateState(String state) => updateWith(state: state);

  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);

  void updateUseAccountAddressToggle(bool useAccountAddress) =>
      updateWith(useAccountAddress: useAccountAddress);

  Future<void> submit() {}

  void updateWith({
    String shippingAddress,
    String city,
    String state,
    String zipCode,
    bool useAccountAddress,
    bool isLoading,
  }) {
    this.shippingAddress = shippingAddress ?? this.shippingAddress;
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.useAccountAddress = useAccountAddress ?? this.useAccountAddress;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
