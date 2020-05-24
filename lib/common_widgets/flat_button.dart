import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomFlatButton extends FlatButton {
  CustomFlatButton({
    @required String text,
    IconData icon,
    Color color,
    Color textColor,
    VoidCallback onPressed,
  })  : assert(text != null),
        super(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (icon != null) Icon(icon),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          color: color,
          onPressed: onPressed,
        );
}
