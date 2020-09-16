import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/prescription_details/prescription_details.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class TreatmentStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.treatmentStep],
    ).value;
    final width = MediaQuery.of(context).size.width;
    if (model.diagnosisOptions != null) {
      return KeyboardDismisser(
        gestures: [GestureType.onTap, GestureType.onVerticalDragDown],
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
                                .where((element) =>
                                    element.medicationName == label)
                                .toList()
                                .first;
                            model.updateTreatmentStepWith(
                                selectedTreatment: treatmentOptions);

                            if (index ==
                                model.diagnosisOptions.treatments.length - 1) {
                              model.treatmentNoteStepState
                                  .currentlySelectedIsOther = true;
                            } else {
                              model.treatmentNoteStepState
                                  .currentlySelectedIsOther = false;
                            }

                            if (!treatmentOptions.notAPrescription) {
                              PrescriptionDetails.show(
                                context: context,
                                treatmentOptions: treatmentOptions,
                                visitReviewViewModel: model,
                              );
                            }
                          } else {
                            TreatmentOptions treatmentOptions = model
                                .diagnosisOptions.treatments
                                .where((element) =>
                                    element.medicationName == label)
                                .toList()
                                .first;
                            String dialogText = treatmentOptions
                                    .notAPrescription
                                ? "Are you sure you want to deselect this treatment?"
                                : "Do you want to deselect this treatment option or do you want to edit it?";
                            final didPressEdit = await PlatformAlertDialog(
                              title: "Deselect Treatment?",
                              content: dialogText,
                              defaultActionText:
                                  treatmentOptions.notAPrescription
                                      ? "No"
                                      : "Edit",
                              cancelActionText: "Deselect",
                            ).show(context);
                            if (!didPressEdit) {
                              model.deselectTreatmentStep(treatmentOptions);
                            } else {
                              TreatmentOptions treatmentOptions = model
                                  .treatmentNoteStepState
                                  .selectedTreatmentOptions
                                  .where((element) =>
                                      element.medicationName == label)
                                  .toList()
                                  .first;
                              if (index ==
                                  model.diagnosisOptions.treatments.length -
                                      1) {
                                model.treatmentNoteStepState
                                    .currentlySelectedIsOther = true;
                              } else {
                                model.treatmentNoteStepState
                                    .currentlySelectedIsOther = false;
                              }
                              model.updateTreatmentStepWith(
                                  selectedTreatment: treatmentOptions);
                              if (!treatmentOptions.notAPrescription) {
                                PrescriptionDetails.show(
                                  context: context,
                                  treatmentOptions: treatmentOptions,
                                  visitReviewViewModel: model,
                                );
                              }
                            }
                          }
                        },
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
        ),
      );
    }
    return EmptyDiagnosis(model: model);
  }
}
