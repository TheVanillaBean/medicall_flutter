import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/coupon.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/account/payment_detail/payment_detail.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/visit_confirmed/confirm_consult.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stripe_payment/stripe_payment.dart';

class MakePayment extends StatelessWidget {
  final MakePaymentViewModel model;

  const MakePayment({@required this.model});

  static Widget create(BuildContext context, Consult consult) {
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    FirestoreDatabase _db = Provider.of<FirestoreDatabase>(context);
    StripeProvider _stripeProvider = Provider.of<StripeProviderBase>(context);
    return ChangeNotifierProvider<MakePaymentViewModel>(
      create: (context) => MakePaymentViewModel(
        userProvider: _userProvider,
        db: _db,
        stripeProvider: _stripeProvider,
        consult: consult,
      ),
      child: Consumer<MakePaymentViewModel>(
        builder: (_, model, __) => MakePayment(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.makePayment,
      arguments: {
        'consult': consult,
      },
    );
  }

  Future<void> _payPressed(BuildContext context) async {
    if (await model.processPayment()) {
      ConfirmConsult.show(context: context);
    } else {
      AppUtil()
          .showFlushBar("There was an error processing your payment.", context);
    }
  }

  Future<void> _applyCoupon(BuildContext context) async {
    try {
      Coupon coupon = await model.processCouponCode();
      FocusScope.of(context).unfocus();
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  void addCard({StripeProvider stripeProvider, BuildContext context}) async {
    this.model.updateWith(isLoading: true);
    PaymentIntent setupIntent = await stripeProvider.addSource();
    this.model.updateWith(isLoading: false);

    bool successfullyAddedCard =
        await stripeProvider.addCard(setupIntent: setupIntent);
    if (successfullyAddedCard) {
      this.model.updateWith(isLoading: false, refreshCards: true);
    } else {
      this.model.updateWith(isLoading: false);
      AppUtil().showFlushBar("There was an error adding your card.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    if (this.model.refreshCards) {
      this.model.retrieveCards();
    }

    String title = model.consult.state != ConsultStatus.ReferralRequested
        ? "Please confirm your payment details and pay below for your visit with ${this.model.consult.providerUser.fullName}, ${this.model.consult.providerUser.professionalTitle}"
        : "Please select a payment method to continue. You will not be charged right now. Once the referral is granted, you will then be asked to pay for this visit.";

    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Close,
        title: "Consult Checkout",
        theme: Theme.of(context),
        onPressed: () => PatientDashboardScreen.show(
          context: context,
          pushReplaceNamed: true,
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildShoppingCart(context: context),
                  SizedBox(height: 12),
                  _buildPriceBreakdown(context: context),
                  _buildCoupon(context: context),
                  SizedBox(height: 18),
                  _buildPaymentDetail(context: context),
                  SizedBox(height: 24),
                  if (model.consult.state != ConsultStatus.ReferralRequested)
                    _buildCheckoutButton(context),
                  if (model.consult.state == ConsultStatus.ReferralRequested)
                    _buildContinueButton(context),
                  if (model.consult.insuranceInfo.coverageResponse ==
                          CoverageResponse.Medicare &&
                      model.coupon == null)
                    _buildMedicareLabel(context),
                  SizedBox(height: 24),
                  if (model.isLoading && !model.userHasCards)
                    CircularProgressIndicator(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingCart({BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (this.model.consultPaid)
            Text(
              "Paid",
              style: Theme.of(context).textTheme.headline6,
            ),
          Expanded(
            flex: 8,
            child: Text(
              "${this.model.consult.symptom} Visit",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            flex: this.model.consultPaid ? 1 : 2,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "\$${this.model.consult.price}",
                  ),
                ],
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildDiscountedTextField(BuildContext context) {
    return [
      TextSpan(
        text: "\$${this.model.consult.price}",
        style: Theme.of(context).textTheme.headline5.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.lineThrough,
            ),
      ),
      TextSpan(
        text:
            "  \$${this.model.consult.price * this.model.coupon.discountMultiplier}",
      ),
    ];
  }

  Widget _buildPriceBreakdown({BuildContext context}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Consult Cost:',
                style: Theme.of(context).textTheme.headline5,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    if (this.model.coupon == null)
                      TextSpan(
                        text: "\$${this.model.consult.price}",
                      ),
                    if (this.model.coupon != null)
                      ..._buildDiscountedTextField(context),
                  ],
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Tax:',
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                '\$0',
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total Cost:',
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    if (this.model.coupon == null)
                      TextSpan(
                        text: "\$${this.model.consult.price}",
                      ),
                    if (this.model.coupon != null)
                      ..._buildDiscountedTextField(context),
                  ],
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                maxLines: 1,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          SizedBox(height: 12.0),
          if (this.model.coupon != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Coupon Discount:',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '\$${model.coupon.discountPercentage}%',
                  style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCoupon({BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(120, 0, 10, 0),
      child: ListTile(
        title: TextFormField(
          onChanged: model.updateCouponCode,
          style: Theme.of(context).textTheme.bodyText1,
          decoration: new InputDecoration(
            labelText: 'Coupon Code',
            labelStyle: Theme.of(context).textTheme.subtitle2,
            hintText: '',
            hintStyle: Theme.of(context).textTheme.subtitle2,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black26,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black26,
                width: 0.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black26,
                width: 0.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black26,
                width: 0.5,
              ),
            ),
            contentPadding: EdgeInsets.all(8),
            isDense: true,
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: OutlinedButton(
              child: Text(
                'Apply',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              onPressed: model.couponCode.isNotEmpty
                  ? () => _applyCoupon(context)
                  : null),
        ),
      ),
    );
  }

  Widget _buildPaymentDetail({BuildContext context}) {
    if (this.model.userHasCards) {
      return _buildCardItem(context: context);
    }
    if (this.model.refreshCards) {
      return CircularProgressIndicator();
    }
    return _buildAddCardBtn(context: context);
  }

  Widget _buildCardItem({BuildContext context}) {
    double width = ScreenUtil.screenWidthDp;
    String title = "";
    if (!model.skipCheckout) {
      title = "Select a payment method. Your default is already selected.";
    } else {
      title = "No need to select a payment method. This is a free visit.";
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        if (!model.skipCheckout)
          ListTile(
            contentPadding: EdgeInsets.only(
              left: width * 0.25,
              right: width * 0.08,
            ),
            dense: false,
            leading: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              child: Image.asset(
                'assets/icon/cards/${this.model.selectedPaymentMethod.card.brand}.png',
                height: 32.0,
              ),
            ),
            title: Text(
              this.model.selectedPaymentMethod.card.brand.toUpperCase() +
                  ' **** ' +
                  this.model.selectedPaymentMethod.card.last4,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: !model.consultPaid && !model.skipCheckout
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => PaymentDetail.show(
                      context: context,
                      paymentModel: this.model,
                    ),
                  )
                : null,
            onTap: !model.consultPaid && !model.skipCheckout
                ? () => PaymentDetail.show(
                      context: context,
                      paymentModel: this.model,
                    )
                : null,
          ),
      ],
    );
  }

  Widget _buildAddCardBtn({BuildContext context}) {
    String title = "";
    if (!model.skipCheckout) {
      title = "Please add a payment method";
    } else {
      title = "No need to add a payment method. This is a free visit.";
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        if (!model.skipCheckout)
          FlatButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Add Card',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            onPressed: model.isLoading || model.skipCheckout
                ? null
                : () => addCard(stripeProvider: model.stripeProvider),
          ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 200,
      child: RoundedLoadingButton(
        controller: model.btnController,
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        onPressed: model.canSubmit ? () => _payPressed(context) : null,
      ),
    );
  }

  //For referrals that have not been paid for yet
  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 200,
      child: RoundedLoadingButton(
        controller: model.btnController,
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        onPressed: () => PatientDashboardScreen.show(context: context),
      ),
    );
  }

  Widget _buildMedicareLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Text(
        "* Because this is a Medicare visit, you will not be charged now, but instead a \$20 hold will be placed on your card.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}
