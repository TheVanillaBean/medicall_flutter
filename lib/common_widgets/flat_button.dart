import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomFlatButton extends FlatButton {
  CustomFlatButton({
    @required String text,
    IconData leadingIcon,
    IconData trailingIcon,
    Color color,
    Color textColor,
    EdgeInsets padding,
    double fontSize = 18,
    VoidCallback onPressed,
  })  : assert(text != null),
        super(
          child: Padding(
            padding:
                padding != null ? padding : EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: <Widget>[
                if (leadingIcon != null)
                  Icon(
                    leadingIcon,
                    color: textColor,
                  ),
                if (leadingIcon != null)
                  SizedBox(
                    width: 30,
                  ),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                  ),
                ),
                if (trailingIcon != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(trailingIcon, color: textColor,),
                    ),
                  ),
              ],
            ),
          ),
          color: color,
          onPressed: onPressed,
        );
}
