import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';

class CloseChat extends StatefulWidget {
  final Consult consult;

  const CloseChat({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.closeChat,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _CloseChatState createState() => _CloseChatState();
}

class _CloseChatState extends State<CloseChat> {
  List<String> reasonLabels;
  String selectedReason;
  bool shouldMedicallContactPatient = false;
  bool submitted;

  bool get canSubmit {
    return selectedReason.length > 0 && !submitted;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
