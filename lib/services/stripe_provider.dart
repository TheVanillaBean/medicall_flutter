import 'package:Medicall/secrets.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stripe_payment/stripe_payment.dart';

abstract class StripeProviderBase {
  Future<PaymentIntent> addSource();
  Future<bool> addCard({PaymentIntent setupIntent});
  Future<PaymentIntentResult> chargePayment(
      {int price, String paymentMethodId});
}

class StripeProvider implements StripeProviderBase {
  StripeProvider() {
    StripePayment.setOptions(StripeOptions(publishableKey: stripeKey));
  }

  @override
  Future<PaymentIntent> addSource() async {
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'createSetupIntent')
          ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call();

    PaymentIntent setupIntent =
        PaymentIntent(clientSecret: result.data["client_secret"]);

    PaymentMethod paymentMethod =
        await StripePayment.paymentRequestWithCardForm(
            CardFormPaymentRequest());

    setupIntent.paymentMethodId = paymentMethod.id;

    return setupIntent;
  }

  @override
  Future<bool> addCard({PaymentIntent setupIntent}) async {
    SetupIntentResult result =
        await StripePayment.confirmSetupIntent(setupIntent);
    return result.status == "succeeded";
  }

  @override
  Future<PaymentIntentResult> chargePayment(
      {int price, String paymentMethodId}) async {
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'createPaymentIntentAndCharge')
          ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'amount': price * 100,
        'payment_method': paymentMethodId,
      },
    );

    final PaymentIntentResult paymentIntentResult =
        PaymentIntentResult.fromJson(result.data);

    return paymentIntentResult;
  }
}
