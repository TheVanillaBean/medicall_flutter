import 'package:Medicall/models/symptoms.dart';
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
    return ListTile(
      title: Text(StringUtils.capitalize(symptom.name)),
      subtitle: Text(symptom.duration),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
