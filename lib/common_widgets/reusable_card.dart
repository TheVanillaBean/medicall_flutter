import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Icon trailing;

  const ReusableCard(
      {@required this.title,
      this.leading,
      this.subtitle,
      this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 2,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          dense: true,
          leading: leading,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}
