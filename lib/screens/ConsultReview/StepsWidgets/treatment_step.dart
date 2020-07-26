import 'package:Medicall/screens/ConsultReview/ReusableWidgets/continue_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/emty_diagnosis_widget.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

import '../visit_review_view_model.dart';

class TreatmentStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.treatmentStep],
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
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
                    child: Text(
                      "Check all that apply",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: width * 0.8,
                    child: CheckboxGroup(
                      labels: model.diagnosisOptions.treatments
                          .map((t) => t.medicationName)
                          .toList(),
                      onSelected: (List<String> checked) => model
                          .updateTreatmentStepWith(selectedTreatments: checked),
                    ),
                  ),
                  ContinueButton(
                    width: width,
                    model: model,
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
