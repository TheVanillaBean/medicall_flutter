import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PrescriptionCheckoutViewModel with ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreDatabase firestoreDatabase;

  String consultId;
  List<TreatmentOptions> treatmentOptions = [];
  String shippingAddress;
  PaymentMethod selectedPaymentMethod;
  bool isLoading;

  PrescriptionCheckoutViewModel({
    @required this.userProvider,
    @required this.firestoreDatabase,
    @required this.treatmentOptions,
    @required this.consultId,
    this.shippingAddress = "",
    this.isLoading = false,
  });

  void updateWith({
    String shippingAddress,
    bool isLoading,
  }) {
    this.shippingAddress = shippingAddress ?? this.shippingAddress;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
