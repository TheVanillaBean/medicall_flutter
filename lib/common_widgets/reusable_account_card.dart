import 'package:flutter/material.dart';

class ReusableAccountCard extends StatelessWidget {
  final String leading;
  final String title;
  final IconButton trailing;
  final VoidCallback onTap;

  const ReusableAccountCard({
    @required this.leading,
    @required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(0, 3, 0, 3),
        dense: true,
        leading: Text(
          leading ?? '',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        title: Transform(
          child: Text(
            title ?? '',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          transform: Matrix4.translationValues(-5, 0.0, 0.0),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
