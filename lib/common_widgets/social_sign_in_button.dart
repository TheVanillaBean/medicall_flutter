import 'dart:ui';

import 'package:flutter/material.dart';

import 'custom_raised_button.dart';

class SocialSignInButton extends CustomRaisedButton {
  SocialSignInButton({
    @required String imgPath,
    @required String text,
    Color color,
    Color textColor,
    VoidCallback onPressed,
  })  : assert(imgPath != null),
        assert(text != null),
        super(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.asset(imgPath),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: Image.asset(imgPath),
                ),
              ],
            ),
          ),
          color: color,
          onPressed: onPressed,
          height: 50,
        );
}
