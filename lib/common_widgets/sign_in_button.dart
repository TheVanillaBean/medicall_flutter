import 'dart:ui';

import 'package:flutter/material.dart';

import 'custom_raised_button.dart';

class SignInButton extends CustomRaisedButton {
  SignInButton({
    @required String text,
    double height,
    Color color,
    Color textColor,
    VoidCallback onPressed,
  })  : assert(text != null),
        super(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 15.0,
              letterSpacing: 1.3,
            ),
          ),
          color: color,
          onPressed: onPressed,
        );
}
