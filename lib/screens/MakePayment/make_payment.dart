import 'dart:ui' as ui;

import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/MakePayment/make_payment_view_model.dart';
import 'package:Medicall/screens/Questions/confirm_consult.dart';
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
      this.consult.state = ConsultStatus.PendingReview;
      await this.model.db.saveConsult(
            consult: this.consult,
            consultId: this.consult.uid,
          );
      return ConfirmConsult.show(context: context);
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
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Make Payment",
        theme: Theme.of(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Text(
              'You are almost done, we just need your method of payment below.',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),
            Text(
              'Today\'s visit costs:',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Card(
              elevation: 2,
              borderOnForeground: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(24, 5, 20, 5),
                dense: true,
                title: Text(
                  consult.symptom,
                  style: Theme.of(context).textTheme.headline5,
                ),
                trailing: Text(
                  "\$${consult.price}",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ReusableRaisedButton(
                  title: 'Pay',
                  onPressed:
                      model.isLoading ? null : () => _payPressed(context),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '256-BIT TLS SECURITY',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            if (model.isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
