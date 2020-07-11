import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardListItem extends StatelessWidget {
  const DashboardListItem({Key key, @required this.consult, this.onTap})
      : super(key: key);
  final Consult consult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        StringUtils.capitalize(consult.providerUser.fullName),
      ),
      subtitle: Text(consult.price.toString()),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
