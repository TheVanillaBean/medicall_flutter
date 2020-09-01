import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stripe_payment/stripe_payment.dart';

class MakePaymentViewModel with ChangeNotifier {
  final UserProvider userProvider;
  final FirestoreDatabase db;
  final StripeProvider stripeProvider;
  final Consult consult;
  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  bool isLoading;
  bool consultPaid;
  bool refreshCards;
  bool userHasCards;
  PaymentMethod selectedPaymentMethod;
  List<PaymentMethod> paymentMethods;

  MakePaymentViewModel({
    @required this.userProvider,
    @required this.db,
    @required this.stripeProvider,
    @required this.consult,
    this.isLoading = false,
    this.refreshCards = true,
    this.userHasCards = false,
    this.consultPaid = false,
  });

  bool get canSubmit {
    return this.selectedPaymentMethod != null && !isLoading;
  }

  Future<bool> processPayment() async {
    PaymentIntentResult paymentIntentResult =
        await this.stripeProvider.chargePaymentForConsult(
              price: this.consult.price,
              paymentMethodId: this.selectedPaymentMethod.id,
              consultId: this.consult.uid,
            );

    updateWith(isLoading: false);
    if (paymentIntentResult.status == "succeeded") {
      this.consult.state = ConsultStatus.PendingReview;
      await this.db.saveConsult(
            consult: this.consult,
            consultId: this.consult.uid,
          );
      updateWith(consultPaid: true);
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
      this.paymentMethods = await this.db.getUserCardSources(uid);
      if (this.paymentMethods.length > 0) {
        this.selectedPaymentMethod = this.paymentMethods.first;
      }
      this.userHasCards = this.selectedPaymentMethod != null;
      updateWith(refreshCards: false);
    }
  }

  void updateWith({
    PaymentMethod paymentMethod,
    bool consultPaid,
    bool isLoading,
    bool refreshCards,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    this.refreshCards = refreshCards ?? this.refreshCards;
    this.selectedPaymentMethod = paymentMethod ?? this.selectedPaymentMethod;
    this.consultPaid = consultPaid ?? this.consultPaid;
    notifyListeners();
  }
}
