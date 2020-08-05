import 'package:Medicall/screens/ConsultReview/ReusableWidgets/continue_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

import '../visit_review_view_model.dart';

class ExamStep extends StatefulWidget {
  @override
  _ExamStepState createState() => _ExamStepState();
}

class _ExamStepState extends State<ExamStep> {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.examStep],
    ).value;
    final width = MediaQuery.of(context).size.width;
    if (model.diagnosisOptions != null)
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SwipeGestureRecognizer(
          onSwipeLeft: () => model.incrementIndex(),
          onSwipeRight: () => model.decrementIndex(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
                      child: Text(
                        "Check all that apply",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: CheckboxGroup(
                        labels: model.diagnosisOptions.exam,
                        itemBuilder: (Checkbox cb, Text txt, int i) {
                          return Row(
                            children: <Widget>[
                              cb,
                              Expanded(
                                child: Text(
                                  txt.data,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          );
                        },
                        onSelected: (List<String> checked) => model
                            .updateExamStepWith(selectedExamOptions: checked),
                        checked: model.examStepState.selectedExamOptions,
                      ),
                    ),
                    if (model.examStepState.selectedExamOptions.length > 0)
                      for (String examOption
                          in model.examStepState.selectedExamOptions)
                        ..._buildLocationItem(examOption, model),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: ContinueButton(
                        width: width,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    return EmptyDiagnosis(model: model);
  }

  List<Widget> _buildLocationItem(
      String examOption, VisitReviewViewModel model) {
    String locationQuestion = examOption.toLowerCase() == "other"
        ? "Enter custom entry for \"Other\""
        : "What is the location of the $examOption? (Optional)";
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          locationQuestion,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TextFormField(
          initialValue: model.examStepState.getExamLocation(examOption),
          autocorrect: false,
          keyboardType: TextInputType.text,
          onChanged: (String text) =>
              model.updateExamStepWith(locationMap: {examOption: text}),
          style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
            ),
            hintStyle: TextStyle(
              color: Color.fromRGBO(100, 100, 100, 1),
            ),
            filled: true,
            fillColor: Colors.grey.withAlpha(20),
            labelText: examOption.toLowerCase() == "other"
                ? "Custom Examination"
                : "Location",
            hintText: 'Optional',
          ),
        ),
      ),
      SizedBox(
        height: 12,
      ),
    ];
  }
}
