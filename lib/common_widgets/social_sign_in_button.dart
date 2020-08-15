import 'dart:ui';

import 'package:flutter/material.dart';

import 'custom_raised_button.dart';

class SocialSignInButton extends CustomRaisedButton {
  SocialSignInButton({
    @required String imgPath,
    @required String text,
    Color color,
    Color textColor,
    BuildContext context,
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
                  style: Theme.of(context).textTheme.bodyText1,
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
