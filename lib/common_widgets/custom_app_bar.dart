import 'package:flutter/material.dart';

enum AppBarType { Back, Close }

class CustomAppBar {
  const CustomAppBar({@required this.title});
  final String title;

  static getAppBar({AppBarType type, String title}) {
    if (type == AppBarType.Back) {
      return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: () {
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
              onPressed: () {
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
