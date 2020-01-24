import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/secrets.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/stripe_payment_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentDetail extends StatefulWidget {
  PaymentDetail({Key key}) : super(key: key);

  _PaymentDetailState createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  @override
  void initState() {
    super.initState();
    StripeSource.setPublishableKey(stripeKey);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      //App Bar
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
            onPressed: () {
              StripeSource.addSource().then((String token) async {
                PaymentService().addCard(token);
                AppUtil().showFlushBar('Card has been added', context);
              });
            },
          )
        ],
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),

      //Content of tabs
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('cards')
              .document(medicallUser.uid)
              .collection('sources')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> cardList = [];
              for (var i = 0; i < snapshot.data.documents.length; i++) {
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
                              Text(snapshot
                                  .data.documents[i].data['card']['brand']
                                  .toString())
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.cancel,
                            ),
                            onPressed: () {
                              PaymentService().removeCard(
                                  snapshot.data.documents[i].documentID);
                            },
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
                              Text(snapshot
                                  .data.documents[i].data['card']['last4']
                                  .toString())
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
