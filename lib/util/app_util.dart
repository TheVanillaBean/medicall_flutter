import 'package:Medicall/components/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class AppUtil {
  static final AppUtil _instance = new AppUtil.internal();
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
      "$msg",
      duration: Duration(seconds: 2),
      textPadding: EdgeInsets.all(10),
      position: ToastPosition.top,
      
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 6.0,
      textStyle: TextStyle(fontSize: 12.0),
    );
      // Fluttertoast.showToast(
      //     msg: msg,
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.TOP,
      //     timeInSecForIos: 1,
      //     fontSize: 12,
      //     backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
      //     textColor: Colors.white);
  }


}
