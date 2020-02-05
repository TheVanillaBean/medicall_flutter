import 'package:flutter/material.dart';

class AppBarState with ChangeNotifier {
  AppBarState();

  bool showAppBar = true;
  String searchInput = '';
  int sortBy = 1;

  void setShowAppBar(bool val) {
    showAppBar = val;
  }

  bool getShowAppBar() {
    return showAppBar;
  }
}
