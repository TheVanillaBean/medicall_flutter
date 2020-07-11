import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/material.dart';

class ConsultListItem extends StatelessWidget {
  final Consult consult;
  final VoidCallback onTap;

  const ConsultListItem({@required this.consult, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Text(StringUtils.capitalize(consult.patientId)),
        subtitle: Text('data'),
        trailing: Text('Active'),
        onTap: onTap,
      ),
    );
  }
}
