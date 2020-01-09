import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final double height;
  final Widget child;
  final Color color;
  final double borderRadius;
  final VoidCallback onPressed;

  const CustomRaisedButton({
    this.height: 50.0,
    this.borderRadius: 25.0,
    this.color,
    this.onPressed,
    this.child,
  }) : assert(borderRadius != null);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RaisedButton(
        child: child,
        color: color,
        disabledColor: color.withOpacity(.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
