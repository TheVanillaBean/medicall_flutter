import 'package:flutter/material.dart';

enum AppBarType { Back, Close }

class CustomAppBar {
  static getAppBar({AppBarType type, String title, Function onPressed}) {
    if (type == AppBarType.Back) {
      return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: onPressed != null
                  ? onPressed
                  : () {
                      Navigator.pop(context);
                    },
            );
          },
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto Thin',
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
      );
    } else {
      return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.grey,
              ),
              onPressed: onPressed != null
                  ? onPressed
                  : () {
                      Navigator.pop(context);
                    },
            );
          },
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto Thin',
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
      );
    }
  }
}
