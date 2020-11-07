import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/prescription_details/prescription_details.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/treatment_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class TreatmentStep extends StatelessWidget {
  final TreatmentNoteStepState model;

  const TreatmentStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.diagnosisStep],
    ).value;
    return ChangeNotifierProvider<TreatmentNoteStepState>(
      create: (context) => TreatmentNoteStepState(
        visitReviewViewModel: visitReviewViewModel,
      ),
      child: Consumer<TreatmentNoteStepState>(
        builder: (_, model, __) => TreatmentStep(
          model: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (model.visitReviewViewModel.diagnosisOptions != null) {
      return KeyboardDismisser(
        gestures: [GestureType.onTap, GestureType.onVerticalDragDown],
        child: SwipeGestureRecognizer(
          onSwipeLeft: () => model.visitReviewViewModel.incrementIndex(),
          onSwipeRight: () => model.visitReviewViewModel.decrementIndex(),
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
                        labels: model
                            .visitReviewViewModel.diagnosisOptions.treatments
                            .map((t) => t.medicationName)
                            .toList(),
                        checked: model.selectedTreatmentOptions
                            .map((e) => e.medicationName)
                            .toList(),
                        onChange: (isChecked, label, index) async {
                          if (isChecked) {
                            TreatmentOptions treatmentOptions = model
                                .visitReviewViewModel
                                .diagnosisOptions
                                .treatments
                                .where((element) =>
                                    element.medicationName == label)
                                .toList()
                                .first;
                            model.updateTreatmentStepWith(
                                selectedTreatment: treatmentOptions);

                            if (index ==
                                model.visitReviewViewModel.diagnosisOptions
                                        .treatments.length -
                                    1) {
                              model.currentlySelectedIsOther = true;
                            } else {
                              model.currentlySelectedIsOther = false;
                            }

                            if (!treatmentOptions.notAPrescription) {
                              PrescriptionDetails.show(
                                context: context,
                                treatmentOptions: treatmentOptions,
                                visitReviewViewModel:
                                    model.visitReviewViewModel,
                              );
                            }
                          } else {
                            TreatmentOptions treatmentOptions = model
                                .visitReviewViewModel
                                .diagnosisOptions
                                .treatments
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
                                  .selectedTreatmentOptions
                                  .where((element) =>
                                      element.medicationName == label)
                                  .toList()
                                  .first;
                              if (index ==
                                  model.visitReviewViewModel.diagnosisOptions
                                          .treatments.length -
                                      1) {
                                model.currentlySelectedIsOther = true;
                              } else {
                                model.currentlySelectedIsOther = false;
                              }
                              model.updateTreatmentStepWith(
                                  selectedTreatment: treatmentOptions);
                              if (!treatmentOptions.notAPrescription) {
                                PrescriptionDetails.show(
                                  context: context,
                                  treatmentOptions: treatmentOptions,
                                  visitReviewViewModel:
                                      model.visitReviewViewModel,
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ContinueButton(
                        title: "Save and Continue",
                        width: width,
                        onTap: this.model.minimumRequiredFieldsFilledOut
                            ? () async {
                                model.visitReviewViewModel.incrementIndex();
                                print("");
                                // model.visitReviewViewModel.updateContinueBtnPressed(true);
                                // model.visitReviewViewModel.incrementIndex();
                                // await model.visitReviewViewModel.saveVisitReviewToFirestore();
                              }
                            : null,
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
    return EmptyDiagnosis(model: model.visitReviewViewModel);
  }
}
