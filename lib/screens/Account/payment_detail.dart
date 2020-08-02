import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Account/payment_list_item.dart';
import 'package:Medicall/screens/Account/payment_list_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentDetail extends StatelessWidget {
  final PaymentDetailViewModel model;
  final FirestoreDatabase firestoreDatabase;
  final User medicallUser;
  final StripeProvider stripeProvider;

  const PaymentDetail({
    @required this.model,
    @required this.firestoreDatabase,
    @required this.medicallUser,
    @required this.stripeProvider,
  });

  static Widget create(BuildContext context) {
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
          model: model,
          firestoreDatabase: _db,
          stripeProvider: _stripeProvider,
          medicallUser: _medicallUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (model.refreshCards) {
      model.refreshCardsStream();
    }

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
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            top: 84.0,
            bottom: 28.0,
          ),
          child: Text(
            'Your payment cards on file:',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
        ),
        StreamBuilder<List<PaymentMethod>>(
          stream: model.paymentMethodsStream.stream,
          builder: (BuildContext context,
              AsyncSnapshot<List<PaymentMethod>> snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: ListItemsBuilder<PaymentMethod>(
                scrollable: false,
                displayEmptyContentView: false,
                snapshot: snapshot,
                itemBuilder: (context, paymentMethod) => PaymentListItem(
                  key: UniqueKey(),
                  paymentMethod: paymentMethod,
                  onDismissed: () => {
                    print("Card deleted"),
                  },
                ),
              ),
            );
          },
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
              : () => addCard(stripeProvider: stripeProvider),
        ),
        if (model.isLoading) CircularProgressIndicator(),
      ],
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
