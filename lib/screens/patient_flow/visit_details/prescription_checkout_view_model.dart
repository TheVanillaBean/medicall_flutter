import 'dart:async';

import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PrescriptionCheckoutViewModel
    with PrescriptionCheckoutValidator, ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;
  final StripeProvider stripeProvider;
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();
  final VisitReviewData visitReviewData;
  final String consultId;

  List<TreatmentOptions> alreadyPaidForPrescriptions = [];
  List<TreatmentOptions> selectedTreatmentOptions = [];
  String shippingAddress;
  String shippingAddressLine2;
  String city;
  String state;
  String zipCode;
  bool useAccountAddress;
  PaymentMethod selectedPaymentMethod;
  List<PaymentMethod> paymentMethods;
  bool isLoading;
  bool refreshCards;
  int totalCost;
  bool userHasCards;

  PrescriptionCheckoutViewModel({
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.visitReviewData,
    @required this.consultId,
    @required this.stripeProvider,
    this.shippingAddress = "",
    this.shippingAddressLine2 = "",
    this.city = "",
    this.state = "",
    this.zipCode = "",
    this.useAccountAddress = true,
    this.isLoading = false,
    this.refreshCards = true,
    this.totalCost = 0,
    this.userHasCards = false,
  }) {
    List<TreatmentOptions> selectedTreatmentOptions = [];
    int cost = 0;
    for (TreatmentOptions treatmentOptions
        in this.visitReviewData.treatmentOptions) {
      if (treatmentOptions.price > 0) {
        if (treatmentOptions.status == TreatmentStatus.PendingPayment) {
          selectedTreatmentOptions.add(treatmentOptions);
        } else {
          this.alreadyPaidForPrescriptions.add(treatmentOptions);
        }
        cost = cost + treatmentOptions.price;
      }
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

  bool get allPrescriptionsPaidFor {
    bool allPaidFor = true;
    this.visitReviewData.treatmentOptions.forEach((element) {
      if (element.status == TreatmentStatus.PendingPayment &&
          element.price > 0) {
        allPaidFor = false;
      }
    });
    return allPaidFor;
  }

  bool get canSubmit {
    if (this.selectedPaymentMethod == null) {
      return false;
    }

    if (allPrescriptionsPaidFor) {
      this.btnController.success();
      return false;
    }

    if (this.useAccountAddress) {
      return !this.isLoading && this.selectedTreatmentOptions.length > 0;
    }

    return this.selectedTreatmentOptions.length > 0 &&
        shippingAddressValidator.isValid(shippingAddress) &&
        cityValidator.isValid(city) &&
        zipCodeValidator.isValid(zipCode) &&
        !isLoading;
  }

  String get shippingAddressErrorTxt {
    bool showErrorText =
        !isLoading && !shippingAddressValidator.isValid(shippingAddress);
    if (showErrorText) {
      return shippingAddress.length > 0
          ? shippingAddressErrorText
          : "Please enter a shipping address";
    }
    return null;
  }

  String get shippingCityErrorText {
    bool showErrorText = !isLoading && !cityValidator.isValid(city);
    if (showErrorText) {
      return city.length > 0 ? cityErrorText : "Please enter a city";
    }
    return null;
  }

  String get shippingZipCodeErrorText {
    bool showErrorText = !isLoading && !zipCodeValidator.isValid(zipCode);
    if (showErrorText) {
      return zipCode.length > 0 ? zipCodeErrorText : "Please enter a zip code";
    }
    return null;
  }

  void updateTreatmentOptions(List<String> medicationNames) {
    List<TreatmentOptions> selectedTreatmentOptions = [];
    int cost = 0;
    for (String name in medicationNames) {
      int index = this
          .visitReviewData
          .treatmentOptions
          .indexWhere((element) => element.medicationName == name);
      if (index > -1) {
        if (this.visitReviewData.treatmentOptions[index].status ==
            TreatmentStatus.PendingPayment) {
          selectedTreatmentOptions
              .add(this.visitReviewData.treatmentOptions[index]);
          cost = cost + this.visitReviewData.treatmentOptions[index].price;
        }
      }
    }
    updateWith(
      selectedTreatments: selectedTreatmentOptions,
      totalCost: cost,
    );
  }

  void updateShippingAddress(String shippingAddress) =>
      updateWith(shippingAddress: shippingAddress);

  void updateShippingAddressLine2(String shippingAddressLine2) =>
      updateWith(shippingAddressLine2: shippingAddressLine2);

  void updateCity(String city) => updateWith(city: city);

  void updateState(String state) => updateWith(state: state);

  void updateZipCode(String zipCode) => updateWith(zipCode: zipCode);

  void updateUseAccountAddressToggle(bool useAccountAddress) =>
      updateWith(useAccountAddress: useAccountAddress);

  Future<bool> updateUserShippingAddress() async {
    updateWith(isLoading: true);

    MedicallUser user = this.userProvider.user;
    if (this.useAccountAddress) {
      user.shippingAddress = user.mailingAddress;
      user.shippingAddressLine2 = user.mailingAddressLine2;
      user.shippingCity = user.mailingCity;
      user.shippingState = user.mailingState;
      user.shippingZipCode = user.mailingZipCode;
    } else {
      user.shippingAddress = this.shippingAddress;
      user.shippingAddressLine2 = this.shippingAddressLine2;
      user.shippingCity = this.city;
      user.shippingState = this.state;
      user.shippingZipCode = this.zipCode;
    }
    await this.firestoreDatabase.setUser(user);
    this.userProvider.user = user;
    return true;
  }

  Future<bool> processPayment() async {
    PaymentIntentResult paymentIntentResult =
        await this.stripeProvider.chargePaymentForPrescription(
              price: this.totalCost,
              paymentMethodId: this.selectedPaymentMethod.id,
              consultId: this.consultId,
            );

    updateWith(isLoading: false);
    if (paymentIntentResult.status == "succeeded") {
      for (TreatmentOptions treatmentOptions in this.selectedTreatmentOptions) {
        treatmentOptions.status = TreatmentStatus.Paid;
      }
      await firestoreDatabase.saveVisitReview(
        consultId: this.consultId,
        visitReviewData: this.visitReviewData,
      );
      List<TreatmentOptions> treatmentsToBeSaved = [];
      for (TreatmentOptions selectedTreatment
          in this.selectedTreatmentOptions) {
        bool includeTreatment = true;
        for (TreatmentOptions alreadyPaidForPrescription
            in this.alreadyPaidForPrescriptions) {
          if (selectedTreatment.medicationName ==
              alreadyPaidForPrescription.medicationName) {
            includeTreatment = false;
          }
        }
        if (includeTreatment) {
          treatmentsToBeSaved.add(selectedTreatment);
        }
      }
      await this.firestoreDatabase.savePrescriptions(
            consultId: this.consultId,
            treatmentOptions: treatmentsToBeSaved,
          );
      this.btnController.success();
      return true;
    } else {
      this.btnController.reset();
      return false;
    }
  }

  Future<void> retrieveCards() async {
    if (this.refreshCards) {
      String uid = this.userProvider.user.uid;
      this.paymentMethods =
          await this.firestoreDatabase.getUserCardSources(uid);
      if (this.paymentMethods.length > 0) {
        this.selectedPaymentMethod = this.paymentMethods.first;
      }
      this.userHasCards = this.selectedPaymentMethod != null;
      updateWith(refreshCards: false);
    }
  }

  void updateWith({
    List<TreatmentOptions> selectedTreatments,
    String shippingAddress,
    String shippingAddressLine2,
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
    this.shippingAddressLine2 =
        shippingAddressLine2 ?? this.shippingAddressLine2;
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
