import 'dart:ui' as ui;

import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';

class MakePayment extends StatelessWidget {
  final Consult consult;

  const MakePayment({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.makePayment,
      arguments: {
        'consult': consult,
      },
    );
  }

  Future<void> _payPressed() async {
//    List<dynamic> sources = await _db.getUserCardSources(_medicallUser.uid);
//
//  if (sources.length == 0) {
//    PaymentIntent setupIntent = await _stripeProvider.addSource();
//    bool addCard = await _stripeProvider.addCard(setupIntent: setupIntent);
//    if (addCard) {
//      return await chargeUsersCard(
//          paymentMethodId: setupIntent.paymentMethodId, context: context);
//    }
//  }
//
//  return await chargeUsersCard(
//      paymentMethodId: sources.first.id, context: context);
  }

//  chargeUsersCard({String paymentMethodId, BuildContext context}) async {
//    setState(() {
//      _isLoading = true;
//    });
//
//    String price = _db.newConsult.price.replaceAll("\$", "");
//    _stripeProvider.chargePayment(
//      price: int.tryParse(_db.newConsult.price.replaceAll("\$", "")),
//      paymentMethodId: paymentMethodId,
//    );
//    await _db.addConsult(
//      context,
//      _db.newConsult,
//      _extImageProvider,
//      medicallUser: _medicallUser,
//    );
//    _extImageProvider.clearImageMemory();
//
//    Route route = MaterialPageRoute(
//        builder: (context) => RouteUserOrderScreen(
//          data: {'user': _medicallUser, 'consult': _db.newConsult},
//        ));
//    return Navigator.of(context).pushReplacement(route);
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make Payment"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            height: MediaQueryData.fromWindow(ui.window).size.height * 1.1,
          ),
          child: Container(
            color: Colors.white,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildChildren(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return <Widget>[
      Text(
        'Checkout',
        style: TextStyle(fontSize: 30),
      ),
      SizedBox(height: 24),
      Text(
        'You are almost done, we just need your method of payment below.',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 24),
      Text(
        'Today\'s visit costs',
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            consult.symptom,
            style: TextStyle(fontSize: 30),
          ),
          Text(
            "\$${consult.price}",
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      SizedBox(height: 32),
      Row(
        children: <Widget>[
          Expanded(
            child: SignInButton(
              color: Colors.green,
              textColor: Colors.white,
              text: "Pay",
              onPressed: _payPressed,
            ),
          )
        ],
      ),
      SizedBox(height: 12),
      Center(
        child: Text(
          '256-BIT TLS SECURITY',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          ),
        ),
      ),
    ];
  }
}
