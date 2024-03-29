import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:stripe_payment/stripe_payment.dart';

abstract class StripeProviderBase {
  Future<PaymentIntent> addSource();
  Future<bool> addCard({PaymentIntent setupIntent});
  Future<PaymentIntentResult> chargePaymentForConsult({
    @required int price,
    @required String paymentMethodId,
  });
  Future<PaymentIntentResult> chargePaymentForPrescription({
    @required int price,
    @required String paymentMethodId,
    @required String consultId,
  });
}

class StripeProvider implements StripeProviderBase {
  StripeProvider({@required stripeKey}) {
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

    try {
      PaymentMethod paymentMethod =
          await StripePayment.paymentRequestWithCardForm(
              CardFormPaymentRequest());
      setupIntent.paymentMethodId = paymentMethod.id;
    } catch (e) {
      return null;
    }

    return setupIntent;
  }

  @override
  Future<bool> addCard({PaymentIntent setupIntent}) async {
    SetupIntentResult result =
        await StripePayment.confirmSetupIntent(setupIntent);
    return result.status == "succeeded";
  }

  @override
  Future<PaymentIntentResult> chargePaymentForConsult({
    @required int price,
    @required String paymentMethodId,
    @required String consultId,
    bool applyCoupon = false,
    String couponCode,
    bool placeHold = false,
  }) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'createPaymentIntentAndChargeForConsultV2')
      ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    if (applyCoupon) {
      parameters = <String, dynamic>{
        'amount': price * 100,
        'payment_method': paymentMethodId,
        'consult_id': consultId,
        'apply_coupon': applyCoupon,
        'coupon_code': couponCode,
      };
    } else {
      parameters = <String, dynamic>{
        'amount': price * 100,
        'payment_method': paymentMethodId,
        'consult_id': consultId,
        'apply_coupon': applyCoupon,
        'place_hold': placeHold,
      };
    }

    final HttpsCallableResult result = await callable.call(parameters);

    final PaymentIntentResult paymentIntentResult =
        PaymentIntentResult.fromJson(result.data);

    return paymentIntentResult;
  }

  @override
  Future<PaymentIntentResult> chargePaymentForPrescription({
    @required int price,
    @required String paymentMethodId,
    @required String consultId,
  }) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'createPaymentIntentAndChargeForPrescription')
      ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'amount': price * 100,
        'payment_method': paymentMethodId,
        'consult_id': consultId,
      },
    );

    final PaymentIntentResult paymentIntentResult =
        PaymentIntentResult.fromJson(result.data);

    return paymentIntentResult;
  }
}
