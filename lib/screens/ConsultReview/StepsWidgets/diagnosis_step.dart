import 'package:Medicall/screens/ConsultReview/ReusableWidgets/continue_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class DiagnosisStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.diagnosisStep],
    ).value;
    final width = MediaQuery.of(context).size.width;
    return LayoutBuilder(
      builder: (context, constraint) {
        return SwipeGestureRecognizer(
          onSwipeLeft: () => model.incrementIndex(),
          onSwipeRight: () => model.decrementIndex(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
                      child: Text(
                        "What is your diagnosis for this patient?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DirectSelect(
                      itemExtent: 60.0,
                      selectedIndex: model.diagnosisStepState.selectedItemIndex,
                      child: CustomSelectionItem(
                        isForList: false,
                        title: model.diagnosisStepState.diagnosis.length > 0
                            ? model.diagnosisStepState.diagnosis
                            : model.consultReviewOptions.diagnosisList[
                                model.diagnosisStepState.selectedItemIndex],
                      ),
                      onSelectedItemChanged: (index) =>
                          model.updateDiagnosis(index),
                      items: _buildDiagnosisItem(model),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
                      child: Text(
                        "Would you like to include a ddx?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: width * 0.8,
                      child: RadioButtonGroup(
                        labels: <String>[
                          "No",
                          "Yes",
                        ],
                        picked:
                            model.diagnosisStepState.includeDDX ? "Yes" : "No",
                        onSelected: (String selected) =>
                            model.updateDiagnosisStepWith(
                                includeDDX: selected == "Yes" ? true : false),
                      ),
                    ),
                    if (model.diagnosisStepState.includeDDX)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(64, 0, 0, 16),
                        child: Container(
                          width: width * 0.8,
                          child: RadioButtonGroup(
                            labels: model.consultReviewOptions
                                .ddxOptions[model.diagnosisStepState.diagnosis],
                            picked: model.diagnosisStepState.ddxOption,
                            onSelected: (String selected) => model
                                .updateDiagnosisStepWith(ddxOption: selected),
                          ),
                        ),
                      ),
                    ContinueButton(
                      width: width,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDiagnosisItem(VisitReviewViewModel model) {
    return model.consultReviewOptions.diagnosisList
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
