import 'package:Medicall/screens/ConsultReview/ReusableWidgets/continue_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class EducationalContentStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.educationalContent],
    ).value;
    final width = MediaQuery.of(context).size.width;
    if (model.diagnosisOptions != null)
      return SwipeGestureRecognizer(
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
                    padding: const EdgeInsets.fromLTRB(12, 32, 0, 12),
                    child: Text(
                      "What educational content would you like to send this patient?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: CheckboxGroup(
                      labels: model.diagnosisOptions.educationalContent
                          .map((e) => e.keys.first.toString())
                          .toList(),
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
                      onSelected: (List<String> checked) =>
                          model.updateEducationalInformation(
                              selectedEducationalOptions: checked),
                    ),
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
      );
    return EmptyDiagnosis(model: model);
  }
}
