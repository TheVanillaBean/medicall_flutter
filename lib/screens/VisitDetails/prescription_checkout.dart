import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/custom_dropdown_formfield.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Account/payment_detail.dart';
import 'package:Medicall/screens/VisitDetails/prescription_checkout_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PrescriptionCheckout extends StatefulWidget {
  final PrescriptionCheckoutViewModel model;

  PrescriptionCheckout({@required this.model});

  static Widget create(
    BuildContext context,
    VisitReviewData visitReviewData,
    String consultId,
  ) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    StripeProvider stripeProvider = Provider.of<StripeProviderBase>(context);
    return ChangeNotifierProvider<PrescriptionCheckoutViewModel>(
      create: (context) => PrescriptionCheckoutViewModel(
        firestoreDatabase: firestoreDatabase,
        userProvider: userProvider,
        stripeProvider: stripeProvider,
        visitReviewData: visitReviewData,
        consultId: consultId,
      ),
      child: Consumer<PrescriptionCheckoutViewModel>(
        builder: (_, model, __) => PrescriptionCheckout(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    String consultId,
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.prescriptionCheckout,
      arguments: {
        'visitReviewData': visitReviewData,
        'consultId': consultId,
      },
    );
  }

  @override
  _PrescriptionCheckoutState createState() => _PrescriptionCheckoutState();
}

class _PrescriptionCheckoutState extends State<PrescriptionCheckout> {
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final FocusNode _shippingAddressFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _zipCodeFocusNode = FocusNode();

  PrescriptionCheckoutViewModel get model => widget.model;

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  void dispose() {
    _shippingAddressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _shippingAddressFocusNode.dispose();
    _cityFocusNode.dispose();
    _zipCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      if (await model.updateUserShippingAddress()) {
        if (await model.processPayment()) {
          AppUtil().showFlushBar(
              "Your payment has been successfully processed!", context);
        } else {
          AppUtil().showFlushBar(
              "There was an error processing your payment.", context);
        }
      } else {
        AppUtil().showFlushBar(
            "There was an error processing your shipping address.", context);
      }
    } catch (e) {
      AppUtil().showFlushBar(e.toString(), context);
    }
  }

  void addCard({StripeProvider stripeProvider}) async {
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
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Prescription Checkout",
        theme: Theme.of(context),
        onPressed: () => Navigator.of(context).pop(),
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
                      "Select the prescription(s) you would like to receive",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildShoppingCart(),
                  SizedBox(height: 12),
                  _buildPriceBreakdown(),
                  _buildAddressCheckbox(),
                  if (!model.useAccountAddress) _buildAddressInputFields(),
                  SizedBox(height: 24),
                  _buildPaymentDetail(),
                  SizedBox(height: 24),
                  _buildCheckoutButton(context),
                  SizedBox(height: 24),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingCart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: CheckboxGroup(
        labels: model.visitReviewData.treatmentOptions
            .map((e) => e.medicationName)
            .toList(),
        itemBuilder: (Checkbox cb, Text txt, int i) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              model.visitReviewData.treatmentOptions[i].status ==
                      TreatmentStatus.PendingPayment
                  ? SizedBox(
                      width: Checkbox.width,
                      child: cb,
                    )
                  : Text(
                      "Paid",
                      style: Theme.of(context).textTheme.headline6,
                    ),
              Expanded(
                flex: 9,
                child: Text(
                  txt.data,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Expanded(
                flex: model.visitReviewData.treatmentOptions[i].status ==
                        TreatmentStatus.Paid
                    ? 2
                    : 1,
                child: Text(
                  "\$${model.visitReviewData.treatmentOptions[i].price}",
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          );
        },
        onSelected: (items) => model.updateTreatmentOptions(items),
        checked: model.selectedTreatmentOptions
            .map((e) => e.medicationName)
            .toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Prescriptions Cost:',
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                '\$${model.totalCost}',
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
                'Shipping:',
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                'FREE',
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
              Text(
                '\$${model.totalCost}',
                style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FormBuilderCheckbox(
        attribute: 'shipping_address',
        readOnly: model.allPrescriptionsPaidFor,
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ship to my mailing address",
                    maxLines: 2,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${model.userProvider.user.mailingAddress} ${model.userProvider.user.mailingCity} ${model.userProvider.user.mailingState} ${model.userProvider.user.mailingZipCode}",
                    maxLines: 3,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
            ),
          ],
        ),
        initialValue: model.useAccountAddress,
        onChanged: (value) =>
            model.updateUseAccountAddressToggle(value as bool),
      ),
    );
  }

  Widget _buildPaymentDetail() {
    if (this.model.userHasCards) {
      return _buildCardItem();
    }
    if (this.model.refreshCards) {
      return CircularProgressIndicator();
    }
    return _buildAddCardBtn();
  }

  Widget _buildCardItem() {
    double width = ScreenUtil.screenWidthDp;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Select a payment method. Your default is already selected.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
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
          trailing: !model.allPrescriptionsPaidFor
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => PaymentDetail.show(
                    context: context,
                    paymentModel: this.model,
                  ),
                )
              : null,
          onTap: !model.allPrescriptionsPaidFor
              ? () => PaymentDetail.show(
                    context: context,
                    paymentModel: this.model,
                  )
              : null,
        ),
      ],
    );
  }

  Widget _buildAddCardBtn() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Please add a payment method",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
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
          onPressed: model.isLoading
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
        onPressed: model.canSubmit ? () => _submit() : null,
      ),
    );
  }

  Widget _buildAddressInputFields() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black26,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            buildShippingAddressTextField(
              controller: _shippingAddressController,
              focusNode: _shippingAddressFocusNode,
              labelText: "Shipping Address",
              hint: "541 Main St",
              enabled: model.isLoading == false,
              errorText: model.shippingAddressErrorText,
              onChanged: model.updateShippingAddress,
            ),
            buildShippingAddressTextField(
              controller: _cityController,
              focusNode: _cityFocusNode,
              labelText: "City",
              hint: "Boston",
              enabled: model.isLoading == false,
              onChanged: model.updateCity,
            ),
            CustomDropdownFormField(
              addPadding: false,
              labelText: 'State',
              onChanged: model.updateState,
              items: model.states,
              selectedItem: model.state,
            ),
            buildShippingAddressTextField(
              textInputType: TextInputType.number,
              maxLength: 5,
              controller: _zipCodeController,
              focusNode: _zipCodeFocusNode,
              labelText: "Zip Code",
              hint: "02101",
              enabled: model.isLoading == false,
              errorText: model.zipCodeErrorText,
              onChanged: model.updateZipCode,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShippingAddressTextField({
    TextEditingController controller,
    FocusNode focusNode,
    String labelText,
    String hint,
    String errorText,
    Function onChanged,
    bool enabled,
    TextInputType textInputType = TextInputType.text,
    int maxLength,
  }) {
    return TextFormField(
      keyboardType: textInputType,
      maxLength: maxLength,
      autocorrect: false,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      autofocus: true,
      style: Theme.of(context).textTheme.bodyText1,
      decoration: InputDecoration(
        counterText: "",
        labelText: labelText,
        errorText: errorText,
        labelStyle: Theme.of(context).textTheme.bodyText1,
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.caption,
        enabled: enabled,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black26,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
      ),
      validator: (input) {
        if (input.isEmpty) {
          return '$labelText is required';
        }
        return null;
      },
    );
  }
}
