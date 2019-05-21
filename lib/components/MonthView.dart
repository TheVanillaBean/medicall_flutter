import 'package:flutter/material.dart';

class MonthView extends StatelessWidget {
  final VoidCallback selectbackward;
  final VoidCallback selectforward;
  final String month;
  MonthView({this.selectbackward, this.selectforward, this.month});
  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: selectbackward,
        ),
        Text(
          month.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18.0,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w300,
              color: Colors.white),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onPressed: selectforward,
        ),
      ],
    ));
  }
}
