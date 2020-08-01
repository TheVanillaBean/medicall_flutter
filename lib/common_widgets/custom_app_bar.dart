import 'package:flutter/material.dart';

enum AppBarType { Back, Close }

class CustomAppBar {
  static getAppBar(
      {AppBarType type,
      String title,
      String subtitle,
      Widget leading,
      List<Widget> actions,
      ThemeData theme,
      Function onPressed,
      Widget progress}) {
    if (type == AppBarType.Back) {
      return AppBar(
        leading: leading != null
            ? leading
            : Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.appBarTheme.iconTheme.color,
                    ),
                    onPressed: onPressed != null
                        ? onPressed
                        : () {
                            Navigator.pop(context);
                          },
                  );
                },
              ),
        actions: actions,
        centerTitle: true,
        title: Column(
          children: <Widget>[
            subtitle != null
                ? Column(
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.appBarTheme.textTheme.headline6,
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: theme.appBarTheme.textTheme.subtitle1,
                      )
                    ],
                  )
                : progress != null && title == null
                    ? progress
                    : Text(
                        title,
                        style: theme.appBarTheme.textTheme.headline6,
                      )
          ],
        ),
      );
    } else {
      return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.close,
                color: theme.appBarTheme.iconTheme.color,
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
          style: theme.appBarTheme.textTheme.headline6,
        ),
      );
    }
  }
}
