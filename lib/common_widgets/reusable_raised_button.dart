import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReusableRaisedButton extends StatelessWidget {
  const ReusableRaisedButton({@required this.title, @required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 200,
      child: RaisedButton(
        color: Theme.of(context).colorScheme.primary,
        disabledColor: Theme.of(context).disabledColor.withOpacity(.3),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
