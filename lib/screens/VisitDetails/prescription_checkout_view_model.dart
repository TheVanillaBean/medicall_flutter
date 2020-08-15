import 'dart:async';

import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PrescriptionCheckoutViewModel
    with PrescriptionCheckoutValidator, ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;
  final StripeProvider stripeProvider;

  String consultId;
  List<TreatmentOptions> treatmentOptions = [];
  String shippingAddress;
  String city;
  String state;
  String zipCode;
  bool useAccountAddress;
  PaymentMethod selectedPaymentMethod;
  List<PaymentMethod> paymentMethods;
  bool isLoading;
  bool refreshCards;

  PrescriptionCheckoutViewModel({
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.treatmentOptions,
    @required this.consultId,
    @required this.stripeProvider,
    this.shippingAddress = "",
    this.city = "",
    this.state = "",
    this.zipCode = "",
    this.useAccountAddress = true,
    this.isLoading = false,
    this.refreshCards = true,
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

  Future<void> retrieveCards() async {
    if (this.refreshCards) {
      String uid = this.userProvider.user.uid;
      this.paymentMethods =
          await this.firestoreDatabase.getUserCardSources(uid);
      this.selectedPaymentMethod = this.paymentMethods.first;
      updateWith(refreshCards: false);
    }
  }

  bool get userHasCards {
    return this.paymentMethods != null && this.paymentMethods.length > 0;
  }

  void updateWith({
    String shippingAddress,
    String city,
    String state,
    String zipCode,
    PaymentMethod paymentMethod,
    bool useAccountAddress,
    bool isLoading,
    bool refreshCards,
  }) {
    this.shippingAddress = shippingAddress ?? this.shippingAddress;
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.useAccountAddress = useAccountAddress ?? this.useAccountAddress;
    this.isLoading = isLoading ?? this.isLoading;
    this.refreshCards = refreshCards ?? this.refreshCards;
    this.selectedPaymentMethod = paymentMethod ?? this.selectedPaymentMethod;
    notifyListeners();
  }
}
