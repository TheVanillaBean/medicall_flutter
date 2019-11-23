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

  void showAlert(String msg, int dur) {
    showToast(
      '$msg',
      duration: Duration(seconds: dur),
      textPadding: EdgeInsets.all(10),
      position: ToastPosition(align: Alignment.topCenter, offset: 0),
      backgroundColor: Colors.white.withOpacity(0.9),
      radius: 4.0,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.black54),
    );
  }
}
