import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Account/payment_list_item.dart';
import 'package:Medicall/screens/Account/payment_list_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentDetail extends StatelessWidget {
  final dynamic paymentModel; //from consult or prescription payment
  final PaymentDetailViewModel model;
  final FirestoreDatabase firestoreDatabase;
  final User medicallUser;
  final StripeProvider stripeProvider;

  const PaymentDetail({
    @required this.paymentModel,
    @required this.model,
    @required this.firestoreDatabase,
    @required this.medicallUser,
    @required this.stripeProvider,
  });

  static Widget create(BuildContext context, dynamic paymentModel) {
    FirestoreDatabase _db = Provider.of<FirestoreDatabase>(context);
    StripeProvider _stripeProvider = Provider.of<StripeProviderBase>(context);
    User _medicallUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider<PaymentDetailViewModel>(
      create: (context) => PaymentDetailViewModel(
        database: _db,
        uid: _medicallUser.uid,
      ),
      child: Consumer<PaymentDetailViewModel>(
        builder: (_, model, __) => PaymentDetail(
          paymentModel: paymentModel,
          model: model,
          firestoreDatabase: _db,
          stripeProvider: _stripeProvider,
          medicallUser: _medicallUser,
        ),
      ),
    );
  }

  //dynamic so this widget can be reused
  static Future<void> show({
    BuildContext context,
    dynamic paymentModel,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.paymentDetail,
      arguments: {
        'model': paymentModel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (model.refreshCards) {
      model.refreshCardsStream();
    }
    ScreenUtil.init(context);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Payment Card",
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
        child: _buildChildren(),
      ),
    );
  }

  Widget _buildChildren() {
    return Container(
      height: ScreenUtil.screenHeightDp - (ScreenUtil.screenHeightDp * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'Your payment cards on file:',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
          StreamBuilder<List<PaymentMethod>>(
            stream: model.paymentMethodsStream.stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<PaymentMethod>> snapshot) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: ListItemsBuilder<PaymentMethod>(
                  displayEmptyContentView: false,
                  snapshot: snapshot,
                  itemBuilder: (context, paymentMethod) => PaymentListItem(
                    key: UniqueKey(),
                    paymentMethod: paymentMethod,
                    onDismissed: () => {
                      print("Card deleted"),
                    },
                    onPressed: this.paymentModel != null
                        ? () {
                            this
                                .paymentModel
                                .updateWith(paymentMethod: paymentMethod);
                            Navigator.of(context).pop();
                          }
                        : null,
                  ),
                ),
              );
            },
          ),
          ReusableRaisedButton(
            title: 'Add Card',
            onPressed: model.isLoading
                ? null
                : () => addCard(stripeProvider: stripeProvider),
            outlined: true,
          ),
          if (model.isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }

  void addCard({StripeProvider stripeProvider}) async {
    model.updateWith(isLoading: true);
    PaymentIntent setupIntent = await stripeProvider.addSource();
    model.updateWith(isLoading: false);

    bool successfullyAddedCard =
        await stripeProvider.addCard(setupIntent: setupIntent);
    if (successfullyAddedCard) {
      model.updateWith(isLoading: true, refreshCards: true);
    }
  }
}
