import 'package:flutter/material.dart';

class EmptyVisits extends StatelessWidget {
  const EmptyVisits({
    Key key,
    this.title = 'Nothing here',
    this.message = 'Add a new item to get started',
  }) : super(key: key);
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/empty-folder.png',
              width: 100,
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
