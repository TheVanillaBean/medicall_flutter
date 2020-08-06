import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisitPrescriptions extends StatelessWidget {
  final Consult consult;
  final VisitReviewData visitReviewData;

  const VisitPrescriptions({
    @required this.consult,
    @required this.visitReviewData,
  });

  static Future<void> show({
    BuildContext context,
    Consult consult,
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitPrescriptions,
      arguments: {
        'consult': consult,
        'visitReviewData': visitReviewData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Prescriptions",
        theme: Theme.of(context),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Provider.of(context).pop();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 40),
        child: TextFormField(
          maxLines: null,
          minLines: 5,
          readOnly: true,
          initialValue: visitReviewData.patientNote,
          autocorrect: false,
          keyboardType: TextInputType.multiline,
          style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
            ),
            hintStyle: TextStyle(
              color: Color.fromRGBO(100, 100, 100, 1),
            ),
            filled: true,
            fillColor: Colors.grey.withAlpha(20),
          ),
        ),
      ),
    );
  }
}
