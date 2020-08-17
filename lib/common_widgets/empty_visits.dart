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
              'assets/images/clipboard.png',
              width: 150,
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
