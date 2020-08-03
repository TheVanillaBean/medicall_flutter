import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final double height;
  final Widget child;
  final Color color;
  final double borderRadius;
  final VoidCallback onPressed;

  const CustomRaisedButton({
    this.height: 50.0,
    this.borderRadius: 14.0,
    this.color = Colors.blue,
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
        disabledColor: Colors.grey[350],
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
