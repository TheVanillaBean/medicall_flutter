import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';

class MakePaymentViewModel with ChangeNotifier {
  bool isLoading;

  final UserProvider userProvider;
  final FirestoreDatabase db;
  final StripeProvider stripeProvider;

  MakePaymentViewModel({
    @required this.userProvider,
    @required this.db,
    @required this.stripeProvider,
    this.isLoading = false,
  });

  Future<List<PaymentMethod>> getPaymentMethods() async {
    updateWith(isLoading: true);

    List<PaymentMethod> sources =
        await db.getUserCardSources(userProvider.user.uid);

    if (sources.length == 0) {
      PaymentIntent setupIntent = await stripeProvider.addSource();
      bool cardAddedSuccessfully =
          await stripeProvider.addCard(setupIntent: setupIntent);

      if (cardAddedSuccessfully) {
        sources = await db.getUserCardSources(userProvider.user.uid);
      }
    }

    return sources;
  }

  Future<bool> chargeUsersCard() async {
    List<PaymentMethod> sources = await getPaymentMethods();
    if (sources.length == 0) {
      return false;
    }

    PaymentIntentResult paymentIntentResult =
        await stripeProvider.chargePayment(
      price: 49,
      paymentMethodId: sources.first.id,
    );

    updateWith(isLoading: false);
    if (paymentIntentResult.status == "succeeded") {
      return true;
    } else {
      return false;
    }
  }

  void updateWith({
    bool isLoading,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
