import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/treatment_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/util/app_util.dart';
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
                        labels: model.medicationNames,
                        checked: model.selectedMedicationNames,
                        itemBuilder: (Checkbox cb, GestureDetector gd,
                            Text medicationName, int i) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              cb,
                              Expanded(child: gd),
                              if (model.isSelectedPrescription(
                                  i, medicationName.data))
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    TreatmentOptions selectedTreatment;

                                    try {
                                      selectedTreatment =
                                          model.selectedTreatment(i);
                                    } catch (e) {
                                      AppUtil().showFlushBar(e, context);
                                    }

                                    final TreatmentOptions
                                        returnedTreatmentOptions =
                                        await Navigator.of(context).pushNamed(
                                      Routes.prescriptionDetails,
                                      arguments: {
                                        'treatmentOptions': selectedTreatment,
                                      },
                                    );

                                    if (returnedTreatmentOptions != null) {
                                      this.model.updateTreatment(
                                          treatmentOptions:
                                              returnedTreatmentOptions);
                                    }
                                  },
                                ),
                            ],
                          );
                        },
                        onChange: (isChecked, label, index) async {
                          TreatmentOptions treatmentOptions = model
                              .visitReviewViewModel
                              .diagnosisOptions
                              .treatments[index];

                          if (isChecked) {
                            this.model.addTreatment(
                                treatmentOptions: treatmentOptions);
                          } else {
                            if (!treatmentOptions.notAPrescription) {
                              //is a prescription
                              final didPressYes = await PlatformAlertDialog(
                                title: "Deselect Treatment?",
                                content:
                                    "Are you sure you want to deselect this treatment?",
                                defaultActionText: "No",
                                cancelActionText: "Deselect",
                              ).show(context);
                              if (!didPressYes) {
                                model.removeTreatment(
                                    treatmentOptions: treatmentOptions);
                              }
                            } else {
                              model.removeTreatment(
                                  treatmentOptions: treatmentOptions);
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
