import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

class CardSelectListItem extends StatelessWidget {
  const CardSelectListItem({
    @required this.paymentMethod,
    this.onPressed,
    this.key,
  });

  final PaymentMethod paymentMethod;
  final VoidCallback onPressed;
  final Key key;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0, right: 0),
      dense: false,
      leading: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        child: Image.asset(
          'assets/icon/cards/${this.paymentMethod.card.brand}.png',
          height: 32.0,
        ),
      ),
      title: Text(this.paymentMethod.card.brand.toUpperCase() +
          ' **** ' +
          this.paymentMethod.card.last4),
      onTap: onPressed,
    );
  }
}
