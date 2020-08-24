import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReusableRaisedButton extends StatelessWidget {
  const ReusableRaisedButton(
      {@required this.title,
      @required this.onPressed,
      this.width,
      this.height,
      this.color,
      this.outlined});
  final String title;
  final int width;
  final int height;
  final Color color;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height != null ? height.toDouble() : 50,
      width: width != null ? width.toDouble() : 200,
      child: RaisedButton(
        elevation: 0,
        color: outlined == true
            ? Theme.of(context).colorScheme.onBackground
            : color != null ? color : Theme.of(context).colorScheme.primary,
        disabledColor: Theme.of(context).disabledColor.withOpacity(.3),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: outlined == true
                    ? color != null
                        ? color
                        : Theme.of(context).colorScheme.primary
                    : Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          side: outlined == true
              ? BorderSide(
                  color: color != null
                      ? color
                      : Theme.of(context).colorScheme.primary)
              : BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
