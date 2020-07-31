import 'package:flutter/material.dart';

enum AppBarType { Back, Close }

class CustomAppBar {
  static getAppBar({
    AppBarType type,
    String title,
    BuildContext context,
    Function onPressed,
  }) {
    if (type == AppBarType.Back) {
      return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).appBarTheme.iconTheme.color,
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
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      );
    } else {
      return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).appBarTheme.iconTheme.color,
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
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      );
    }
  }
}
