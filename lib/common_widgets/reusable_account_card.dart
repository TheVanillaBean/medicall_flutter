import 'package:flutter/material.dart';

class ReusableAccountCard extends StatelessWidget {
  final String leading;
  final String title;
  final VoidCallback onTap;

  const ReusableAccountCard({
    @required this.leading,
    @required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      borderOnForeground: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        dense: true,
        leading: Text(
          leading ?? '',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        title: Transform(
          child: Text(
            title ?? '',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          transform: Matrix4.translationValues(-10, 0.0, 0.0),
        ),
        onTap: onTap,
      ),
    );
  }
}
