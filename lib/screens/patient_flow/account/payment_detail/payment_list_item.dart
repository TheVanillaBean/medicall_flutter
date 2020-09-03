import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentListItem extends StatelessWidget {
  const PaymentListItem({
    @required this.paymentMethod,
    this.onPressed,
    this.key,
    this.onDismissed,
  });

  final PaymentMethod paymentMethod;
  final VoidCallback onPressed;
  final Key key;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Dismissible(
            background: Container(color: Colors.red),
            key: key,
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => onDismissed(),
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure you want to delete this payment method?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE")),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
            },
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
              dense: true,
              leading: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                child: Image.asset(
                  'assets/icon/cards/${paymentMethod.card.brand}.png',
                  height: 32.0,
                ),
              ),
              title: Text(paymentMethod.card.brand.toUpperCase() +
                  ' **** ' +
                  paymentMethod.card.last4),
              onTap: onPressed,
            ),
          ),
        ),
      ],
    );
  }
}
