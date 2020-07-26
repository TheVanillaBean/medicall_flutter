import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/continue_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/emty_diagnosis_widget.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details.dart';
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
                      checked: model
                          .treatmentNoteStepState.selectedTreatmentOptions
                          .map((e) => e.medicationName)
                          .toList(),
                      onChange: (isChecked, label, index) async {
                        if (isChecked) {
                          TreatmentOptions treatmentOptions = model
                              .diagnosisOptions.treatments
                              .where(
                                  (element) => element.medicationName == label)
                              .toList()
                              .first;
                          model.updateTreatmentStepWith(
                              selectedTreatment: treatmentOptions);
                          PrescriptionDetails.show(
                            context: context,
                            treatmentOptions: treatmentOptions,
                            visitReviewViewModel: model,
                          );
                        } else {
                          final didPressEdit = await PlatformAlertDialog(
                            title: "Deselect Treatment?",
                            content:
                                "Do you want to deselect this treatment option or do you want to edit it?",
                            defaultActionText: "Edit",
                            cancelActionText: "Deselect",
                          ).show(context);
                          if (!didPressEdit) {
                            TreatmentOptions treatmentOptions = model
                                .diagnosisOptions.treatments
                                .where((element) =>
                                    element.medicationName == label)
                                .toList()
                                .first;
                            model.deselectTreatmentStep(treatmentOptions);
                          } else {
                            TreatmentOptions treatmentOptions = model
                                .diagnosisOptions.treatments
                                .where((element) =>
                                    element.medicationName == label)
                                .toList()
                                .first;
                            model.updateTreatmentStepWith(
                                selectedTreatment: treatmentOptions);
                            PrescriptionDetails.show(
                              context: context,
                              treatmentOptions: treatmentOptions,
                              visitReviewViewModel: model,
                            );
                          }
                        }
                      },
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
