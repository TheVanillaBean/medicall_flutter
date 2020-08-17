import 'dart:async';

import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/user_model_base.dart';
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
  List<TreatmentOptions> selectedTreatmentOptions = [];
  String shippingAddress;
  String city;
  String state;
  String zipCode;
  bool useAccountAddress;
  PaymentMethod selectedPaymentMethod;
  List<PaymentMethod> paymentMethods;
  bool isLoading;
  bool refreshCards;
  int totalCost;

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
    this.totalCost = 0,
  }) {
    List<TreatmentOptions> selectedTreatmentOptions = [];
    int cost = 0;
    for (TreatmentOptions treatmentOptions in this.treatmentOptions) {
      if (treatmentOptions.status == TreatmentStatus.PendingPayment) {
        selectedTreatmentOptions.add(treatmentOptions);
      }
      cost = cost + treatmentOptions.price;
    }
    this.selectedTreatmentOptions = selectedTreatmentOptions;
    this.totalCost = cost;
  }

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

  void updateTreatmentOptions(List<String> medicationNames) {
    List<TreatmentOptions> selectedTreatmentOptions = [];
    int cost = 0;
    for (String name in medicationNames) {
      int index = this
          .treatmentOptions
          .indexWhere((element) => element.medicationName == name);
      if (index > -1) {
        selectedTreatmentOptions.add(this.treatmentOptions[index]);
        cost = cost + this.treatmentOptions[index].price;
      }
    }
    updateWith(
      selectedTreatments: selectedTreatmentOptions,
      totalCost: cost,
    );
  }

  void updateShippingAddress(String shippingAddress) =>
      updateWith(shippingAddress: shippingAddress);

  void updateCity(String city) => updateWith(city: city);

  void updateState(String state) => updateWith(state: state);

  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);

  void updateUseAccountAddressToggle(bool useAccountAddress) =>
      updateWith(useAccountAddress: useAccountAddress);

  Future<bool> updateUserShippingAddress() async {
    updateWith(isLoading: true);

    User user = this.userProvider.user;
    if (this.useAccountAddress) {
      user.shippingAddress = user.mailingAddress;
      user.shippingCity = user.mailingCity;
      user.shippingState = user.mailingState;
      user.shippingZipCode = user.mailingZipCode;
    } else {
      if (!canSubmit) {
        updateWith(isLoading: false);
        return false;
      } else {
        user.shippingAddress = this.shippingAddress;
        user.shippingCity = this.city;
        user.shippingState = this.state;
        user.shippingZipCode = this.zipCode;
      }
    }
    await this.firestoreDatabase.setUser(user);
    this.userProvider.user = user;
    return true;
  }

  Future<bool> processPayment() async {
    PaymentIntentResult paymentIntentResult =
        await this.stripeProvider.chargePayment(
              price: this.totalCost,
              paymentMethodId: this.selectedPaymentMethod.id,
            );

    updateWith(isLoading: false);
    if (paymentIntentResult.status == "succeeded") {
      for (TreatmentOptions treatmentOptions in this.selectedTreatmentOptions) {
        treatmentOptions.status = TreatmentStatus.Paid;
      }
      await this.firestoreDatabase.savePrescriptions(
            consultId: this.consultId,
            treatmentOptions: this.selectedTreatmentOptions,
          );
      return true;
    } else {
      return false;
    }
  }

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
    List<TreatmentOptions> selectedTreatments,
    String shippingAddress,
    String city,
    String state,
    String zipCode,
    PaymentMethod paymentMethod,
    bool useAccountAddress,
    bool isLoading,
    bool refreshCards,
    int totalCost,
  }) {
    this.selectedTreatmentOptions =
        selectedTreatments ?? this.selectedTreatmentOptions;
    this.shippingAddress = shippingAddress ?? this.shippingAddress;
    this.city = city ?? this.city;
    this.state = state ?? this.state;
    this.zipCode = zipCode ?? this.zipCode;
    this.useAccountAddress = useAccountAddress ?? this.useAccountAddress;
    this.isLoading = isLoading ?? this.isLoading;
    this.refreshCards = refreshCards ?? this.refreshCards;
    this.selectedPaymentMethod = paymentMethod ?? this.selectedPaymentMethod;
    this.totalCost = totalCost ?? this.totalCost;
    notifyListeners();
  }
}
