import 'dart:ui' as ui;

import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/MakePayment/make_payment_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MakePayment extends StatelessWidget {
  final MakePaymentViewModel model;
  final Consult consult;

  const MakePayment({@required this.consult, @required this.model});

  static Widget create(BuildContext context, Consult consult) {
    UserProvider _userProvider = Provider.of<UserProvider>(context);
    FirestoreDatabase _db = Provider.of<FirestoreDatabase>(context);
    StripeProvider _stripeProvider = Provider.of<StripeProviderBase>(context);
    return ChangeNotifierProvider<MakePaymentViewModel>(
      create: (context) => MakePaymentViewModel(
        userProvider: _userProvider,
        db: _db,
        stripeProvider: _stripeProvider,
      ),
      child: Consumer<MakePaymentViewModel>(
        builder: (_, model, __) => MakePayment(
          model: model,
          consult: consult,
        ),
      ),
    );
  }

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

  Future<void> _payPressed(BuildContext context) async {
    bool successfullyChargedCard = await model.chargeUsersCard();
    if (successfullyChargedCard) {
      return PatientDashboardScreen.show(
          context: context, pushReplaceNamed: true);
    } else {
      AppUtil().showFlushBar(
        "Payment failed. Please contact customer support.",
        context,
      );
    }
  }

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
                  children: _buildChildren(
                    context: context,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren({
    BuildContext context,
  }) {
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
              onPressed: model.isLoading ? null : () => _payPressed(context),
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
      SizedBox(height: 24),
      if (model.isLoading)
        Center(
          child: CircularProgressIndicator(),
        ),
    ];
  }
}
