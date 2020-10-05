import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VisitDocNote extends StatelessWidget {
  final Consult consult;
  final VisitReviewData visitReviewData;

  const VisitDocNote({@required this.consult, @required this.visitReviewData});

  static Future<void> show({
    BuildContext context,
    Consult consult,
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitDocNote,
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
        title: "Provider Note",
        theme: Theme.of(context),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.patientDashboard);
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: SelectableText(
          visitReviewData
              .patientNote.introductionTemplate.template.values.first,
          cursorColor: Theme.of(context).colorScheme.primary,
          strutStyle:
              StrutStyle.fromTextStyle(Theme.of(context).textTheme.bodyText1),
          showCursor: true,
          toolbarOptions: ToolbarOptions(
            copy: true,
            selectAll: true,
            cut: false,
            paste: false,
          ),
          style: Theme.of(context).textTheme.bodyText1,
          scrollPhysics: ClampingScrollPhysics(),
        ),
      ),
    );
  }
}
