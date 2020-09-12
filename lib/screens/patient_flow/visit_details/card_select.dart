import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/visit_details/card_select_list_item.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CardSelect extends StatelessWidget {
  final dynamic model;

  const CardSelect({@required this.model});

  //dynamic so this widget can be reused
  static Future<void> show({
    BuildContext context,
    dynamic model,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.cardSelect,
      arguments: {
        'model': model,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Select Payment Method",
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 84.0,
                bottom: 28.0,
              ),
              child: Text(
                'Please select one of your payment methods:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: ListItemsBuilder<PaymentMethod>(
                scrollable: false,
                displayEmptyContentView: false,
                snapshot: null,
                itemsList: model.paymentMethods,
                itemBuilder: (context, paymentMethod) => CardSelectListItem(
                  key: UniqueKey(),
                  paymentMethod: paymentMethod,
                  onPressed: () {
                    model.updateWith(paymentMethod: paymentMethod);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
