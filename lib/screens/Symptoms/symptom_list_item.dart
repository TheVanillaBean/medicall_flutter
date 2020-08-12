import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SymptomListItem extends StatelessWidget {
  const SymptomListItem({Key key, @required this.symptom, this.onTap})
      : super(key: key);
  final Symptom symptom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.fromLTRB(25, 5, 25, 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        dense: true,
        title: Text(
          StringUtils.capitalize(
            symptom.name,
          ),
          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16),
        ),
        subtitle: Text(
          symptom.duration,
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
