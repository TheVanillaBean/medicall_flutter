import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class AppUtil {
  static final AppUtil _instance = AppUtil.internal();
  static bool networkStatus;

  AppUtil.internal();

  factory AppUtil() {
    return _instance;
  }

  bool isNetworkWorking() {
    return networkStatus;
  }

  void showAlert(String msg) {
    showToast(
      '$msg',
      duration: Duration(seconds: 5),
      textPadding: EdgeInsets.all(10),
      position: ToastPosition.top,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 6.0,
      textStyle: TextStyle(fontSize: 16.0),
    );
  }
}
