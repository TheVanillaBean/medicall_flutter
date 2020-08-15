import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final String subtitle;
  final double elevation;
  final VoidCallback onTap;
  final Widget trailing;

  const ReusableCard(
      {@required this.title,
      this.leading,
      this.elevation,
      this.subtitle,
      this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation != null ? elevation : 2,
      borderOnForeground: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        isThreeLine: false,
        contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
        dense: true,
        leading: leading,
        title: title,
        subtitle: Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
