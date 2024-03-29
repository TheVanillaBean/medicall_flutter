import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/coupon.dart';
import 'package:Medicall/models/insurance_info.dart';
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
  String couponCode;
  Coupon coupon;
  bool skipCheckout;

  MakePaymentViewModel({
    @required this.userProvider,
    @required this.db,
    @required this.stripeProvider,
    @required this.consult,
    this.isLoading = false,
    this.refreshCards = true,
    this.userHasCards = false,
    this.consultPaid = false,
    this.couponCode = "",
    this.coupon,
    this.skipCheckout = false,
  });

  bool get canSubmit {
    return (this.selectedPaymentMethod != null || this.skipCheckout) &&
        !isLoading;
  }

  Future<Coupon> processCouponCode() async {
    updateWith(isLoading: true);
    Coupon coupon = await this.db.getCoupon(this.couponCode);
    if (coupon != null) {
      if (!coupon.enabled || coupon.remainingUses == 0) {
        updateWith(isLoading: false);
        throw "This coupon has expired";
      }
      if (coupon.discountPercentage == 100) {
        updateWith(skipCheckout: true);
      }
      updateWith(isLoading: false, coupon: coupon);
      return coupon;
    } else {
      updateWith(isLoading: false);
      throw "A coupon with that code does not exist";
    }
  }

  Future<bool> processPayment({Coupon coupon}) async {
    if (this.skipCheckout) {
      this.updateConsultStatus();
      return true;
    }

    PaymentIntentResult paymentIntentResult;

    if (this.coupon == null) {
      if (this.consult.insuranceInfo.coverageResponse ==
          CoverageResponse.Medicare) {
        paymentIntentResult = await this.stripeProvider.chargePaymentForConsult(
              price: this.consult.price,
              paymentMethodId: this.selectedPaymentMethod.id,
              consultId: this.consult.uid,
              placeHold: true,
            );
      } else {
        paymentIntentResult = await this.stripeProvider.chargePaymentForConsult(
              price: this.consult.price,
              paymentMethodId: this.selectedPaymentMethod.id,
              consultId: this.consult.uid,
            );
      }
    } else {
      paymentIntentResult = await this.stripeProvider.chargePaymentForConsult(
            price: this.consult.price,
            paymentMethodId: this.selectedPaymentMethod.id,
            consultId: this.consult.uid,
            applyCoupon: true,
            couponCode: this.coupon.code,
          );
    }

    updateWith(isLoading: false);
    if (paymentIntentResult.status == "succeeded" ||
        paymentIntentResult.status == "requires_capture") {
      this.updateConsultStatus();
      return true;
    } else {
      this.btnController.reset();
      return false;
    }
  }

  Future<void> updateConsultStatus() async {
    this.consult.state = ConsultStatus.PendingReview;
    if (this.coupon != null) {
      this.consult.coupon = coupon.code;
    }
    await this.db.saveConsult(
          consult: this.consult,
          consultId: this.consult.uid,
        );
    updateWith(consultPaid: true);
    this.btnController.success();
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

  void updateCouponCode(String couponCode) =>
      updateWith(couponCode: couponCode);

  void updateWith({
    PaymentMethod paymentMethod,
    bool consultPaid,
    bool isLoading,
    bool refreshCards,
    String couponCode,
    Coupon coupon,
    bool skipCheckout,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    this.refreshCards = refreshCards ?? this.refreshCards;
    this.selectedPaymentMethod = paymentMethod ?? this.selectedPaymentMethod;
    this.consultPaid = consultPaid ?? this.consultPaid;
    this.couponCode = couponCode ?? this.couponCode;
    this.coupon = coupon ?? this.coupon;
    this.skipCheckout = skipCheckout ?? this.skipCheckout;
    notifyListeners();
  }
}
