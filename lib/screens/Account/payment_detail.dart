import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Account/payment_list_item.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirestoreDatabase _db = Provider.of<FirestoreDatabase>(context);
    StripeProvider _stripeProvider = Provider.of<StripeProviderBase>(context);
    MedicallUser medicallUser = Provider.of<UserProvider>(context).medicallUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Payment Cards',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addCard(stripeProvider: _stripeProvider),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              left: 24.0,
              top: 84.0,
              right: 24.0,
              bottom: 32.0,
            ),
            child: Text(
              'Your payment cards on file:',
              style: TextStyle(
                fontFamily: 'SourceSansPro',
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ),
          FutureBuilder<AsyncSnapshot<List<PaymentMethod>>>(
            future: _db.getUserCardSources(medicallUser.uid),
            builder: (BuildContext context,
                AsyncSnapshot<AsyncSnapshot<List<PaymentMethod>>> snapshot) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: ListItemsBuilder<PaymentMethod>(
                    snapshot: snapshot.data,
                    itemBuilder: (context, paymentMethod) => PaymentListItem(
                      key: UniqueKey(),
                      paymentMethod: paymentMethod,
                      onDismissed: () => {
                        print("Card deleted"),
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void addCard({StripeProvider stripeProvider}) async {
    PaymentIntent setupIntent = await stripeProvider.addSource();

    await stripeProvider.addCard(setupIntent: setupIntent);
  }
}
