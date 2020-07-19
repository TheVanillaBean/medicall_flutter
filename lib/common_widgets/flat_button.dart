import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomFlatButton extends FlatButton {
  CustomFlatButton({
    @required String text,
    IconData leadingIcon,
    IconData trailingIcon,
    Color color,
    Color textColor,
    double fontSize = 18,
    VoidCallback onPressed,
  })  : assert(text != null),
        super(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (leadingIcon != null) Icon(leadingIcon),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                  ),
                ),
                if (trailingIcon != null) Icon(trailingIcon),
              ],
            ),
          ),
          color: color,
          onPressed: onPressed,
        );
}
