import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';

class ConsultDetailScreen extends StatelessWidget {
  final Consult consult;
  const ConsultDetailScreen({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.consultDetail,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
