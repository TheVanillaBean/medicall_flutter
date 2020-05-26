import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentDetail extends StatefulWidget {
  PaymentDetail({Key key}) : super(key: key);

  _PaymentDetailState createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  MyStripeProvider _stripeProvider;
  Database _db;
  MedicallUser medicallUser = MedicallUser();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _db = Provider.of<Database>(context);
    _stripeProvider = Provider.of<MyStripeProvider>(context);
    medicallUser = Provider.of<UserProvider>(context).medicallUser;
    return Scaffold(
        //App Bar
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Payment Cards',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                PaymentIntent setupIntent = await _stripeProvider.addSource();
                await _stripeProvider.addCard(setupIntent: setupIntent);
              },
            )
          ],
        ),

        //Content of tabs
        body: FutureBuilder(
            future: _db.getUserCardSources(medicallUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.length > 0) {
                List<PaymentMethod> paymentList = snapshot.data;
                List<Widget> cardList = [];
                for (var i = 0; i < snapshot.data.length; i++) {
                  cardList.add(
                    Container(
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withAlpha(70)),
                                bottom: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withAlpha(70)))),
                        child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.payment),
                                Text(paymentList[i].card.brand)
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.cancel,
                              ),
                              onPressed: null,
                            ),
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                Icon(
                                  Icons.trip_origin,
                                  size: 12,
                                  color: Theme.of(context).disabledColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(paymentList[i].card.last4)
                              ],
                            ))),
                  );
                }
                return Column(
                  children: cardList,
                );
              } else {
                return Column(
                  children: <Widget>[
                    Container(
                        child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(Icons.payment), Text('---')],
                      ),
                      title: Text('no cards'),
                    ))
                  ],
                );
              }
            }));
  }
}
