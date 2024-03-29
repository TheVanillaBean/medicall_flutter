import 'package:flutter/material.dart';

class IntroButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const IntroButton({Key key, this.onPressed, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        buttonColor: Colors.transparent,
      ),
      child: FlatButton(
        onPressed: onPressed,
        child: child,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
