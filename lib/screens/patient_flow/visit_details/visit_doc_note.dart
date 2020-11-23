import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/services/database.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_rich_text/super_rich_text.dart';

class VisitDocNote extends StatelessWidget {
  final Consult consult;
  final VisitReviewData visitReviewData;

  const VisitDocNote({@required this.consult, @required this.visitReviewData});

  static Future<void> show({
    BuildContext context,
    Consult consult,
    VisitReviewData visitReviewData,
  }) async {
    FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    consult.patientReviewNotifications = 0;
    await database.saveConsult(consult: consult, consultId: consult.uid);
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
      body: Scrollbar(
        child: FadingEdgeScrollView.fromSingleChildScrollView(
          child: SingleChildScrollView(
            controller: ScrollController(),
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: _buildRichText(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(BuildContext context) {
    return SuperRichText(
      text: patientNote,
      strutStyle:
          StrutStyle.fromTextStyle(Theme.of(context).textTheme.bodyText1),
      style: Theme.of(context).textTheme.bodyText1,
      othersMarkers: [
        MarkerText.withSameFunction(
          marker: '<bold>',
          function: () => {},
          onError: (msg) => print('$msg'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String get patientNote {
    String note = "";

    if (visitReviewData.patientNote.hasIntroduction) {
      note += "\n<bold>Introduction:<bold>\n\n";
      note += visitReviewData
          .patientNote.introductionTemplate.template.values.first;
    }

    if (visitReviewData.patientNote.hasUnderstandingDiagnosis) {
      note += "\n<bold>Understanding The Diagnosis:<bold>\n\n";
      note += visitReviewData
          .patientNote.understandingDiagnosisTemplate.template.values.first;
    }

    if (visitReviewData.patientNote.hasCounseling) {
      note += "\n<bold>Counseling:<bold>\n\n";
      note +=
          visitReviewData.patientNote.counselingTemplate.template.values.first;
    }

    if (visitReviewData.patientNote.hasTreatmentRecommendations) {
      note += "\n<bold>Treatment Recommendations:<bold>\n";
      note +=
          "\nIn your particular case, I recommend the following treatment recommendations:\n\n";
      for (String value in visitReviewData
          .patientNote.treatmentRecommendationsTemplate.template.values) {
        note += value;
      }
    }

    if (visitReviewData.patientNote.hasFurtherTesting) {
      note += "\n<bold>Further Testing:<bold>\n\n";
      note += visitReviewData
          .patientNote.furtherTestingTemplate.template.values.first;
    }

    if (visitReviewData.patientNote.hasConclusion) {
      note += "\n<bold>Conclusion:<bold>\n\n";
      note +=
          visitReviewData.patientNote.conclusionTemplate.template.values.first;
    }

    return note;
  }
}
