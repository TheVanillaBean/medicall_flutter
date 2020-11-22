import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CloseChat extends StatefulWidget {
  final Consult consult;

  const CloseChat({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    await database.saveConsult(consult: consult, consultId: consult.uid);
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
  List<String> reasonLabels = [];
  String selectedReason;
  bool shouldMedicallContactPatient = false;
  bool submitted;

  bool get canSubmit {
    return selectedReason.length > 0 && !submitted;
  }

  Future<void> submit() async {
    updateWith(submitted: true);
    Map<String, dynamic> visitClosed = {
      VisitClosedKeys.REASON: this.selectedReason,
      VisitClosedKeys.CONTACT_PATIENT: this.shouldMedicallContactPatient,
    };
    widget.consult.visitClosed = visitClosed;
  }

  void updateWith({
    bool submitted,
  }) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Close Chat",
        theme: Theme.of(context),
      ),
      body: Column(),
    );
  }
}
