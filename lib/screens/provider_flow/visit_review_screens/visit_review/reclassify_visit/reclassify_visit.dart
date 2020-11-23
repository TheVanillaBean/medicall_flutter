import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reclassify_visit/reclassify_visit_view_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/direct_select.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review.dart';
import 'package:Medicall/services/database.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReclassifyVisit extends StatelessWidget {
  final ReclassifyVisitViewModel model;

  const ReclassifyVisit({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
    List<String> totalSymptoms,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return ChangeNotifierProvider<ReclassifyVisitViewModel>(
      create: (context) => ReclassifyVisitViewModel(
        firestoreDatabase: firestoreDatabase,
        consult: consult,
        totalSymptoms: totalSymptoms,
      ),
      child: Consumer<ReclassifyVisitViewModel>(
        builder: (_, model, __) => ReclassifyVisit(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    Consult consult,
    List<String> totalSymptoms,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.reclassifyVisit,
      arguments: {
        'consult': consult,
        "totalSymptoms": totalSymptoms,
      },
    );
  }

  Future<void> _btnPressed(BuildContext context) async {
    await navigateToVisitReviewScreen(context);
  }

  Future<void> navigateToVisitReviewScreen(BuildContext context) async {
    ConsultReviewOptions options;
    if (model.reclassifyVisit) {
      options = await model.firestoreDatabase
          .consultReviewOptions(symptomName: model.visitClassification);
      model.consult.providerReclassified = true;
      model.consult.reclassifiedVisit = model.visitClassification;
    } else {
      options = await model.firestoreDatabase
          .consultReviewOptions(symptomName: model.consult.symptom);
      model.consult.providerReclassified = false;
      model.consult.reclassifiedVisit = "";
    }
    VisitReviewData visitReviewData = await model.firestoreDatabase
        .visitReviewStream(consultId: model.consult.uid)
        .first;

    DiagnosisOptions diagnosisOptions;

    if (visitReviewData == null) {
      visitReviewData = VisitReviewData();
    } else {
      String symptom = model.consult.providerReclassified
          ? model.consult.reclassifiedVisit
          : model.consult.symptom;
      diagnosisOptions =
          await model.firestoreDatabase.consultReviewDiagnosisOptions(
        symptomName: symptom,
        diagnosis: visitReviewData.diagnosis,
      );
    }
    options.diagnosisList.insert(0, "Select a Diagnosis");
    await model.firestoreDatabase
        .saveConsult(consultId: model.consult.uid, consult: model.consult);

    return VisitReview.show(
      context: context,
      consult: model.consult,
      consultReviewOptions: options,
      visitReviewData: visitReviewData,
      diagnosisOptions: diagnosisOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Reclassify Visit",
        theme: Theme.of(context),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 32, 8, 12),
                  child: Text(
                    "The patient gave this visit a classification of ${model.consult.symptom}. Would you like to reclassify this visit?",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: width * 0.8,
                  child: RadioButtonGroup(
                    activeColor: Theme.of(context).colorScheme.primary,
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    labels: <String>[
                      "No",
                      "Yes",
                    ],
                    picked: model.reclassifyVisit ? "Yes" : "No",
                    onSelected: (String selected) {
                      model.updateClassifyStepWith(
                          reclassify: selected == "Yes" ? true : false);
                    },
                  ),
                ),
                if (model.reclassifyVisit) SizedBox(height: 8),
                if (model.reclassifyVisit)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
                    child: Text(
                      "Reclassify the visit below",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (model.reclassifyVisit)
                  DirectSelect(
                    itemExtent: 60.0,
                    selectedIndex: model.selectedItemIndex,
                    child: CustomSelectionItem(
                      isForList: false,
                      title: model.totalSymptoms[model.selectedItemIndex],
                    ),
                    onSelectedItemChanged: (index) =>
                        model.updateClassifyStepWith(
                      reclassify: true,
                      selectedItemIndex: index,
                    ),
                    items: _buildSymptomItem(),
                  ),
                SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: width * .5,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ReusableRaisedButton(
                          title: "Save and Continue",
                          onPressed: model.minimumRequiredFieldsFilledOut
                              ? () => _btnPressed(context)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildSymptomItem() {
    return model.totalSymptoms
        .map((val) => CustomSelectionItem(
              title: val,
            ))
        .toList();
  }
}

class CustomSelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const CustomSelectionItem({Key key, this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: EdgeInsets.all(10.0),
            )
          : Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: AutoSizeText(
        title,
        style: TextStyle(fontSize: 20),
        maxLines: 2,
      ),
    );
  }
}
