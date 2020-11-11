import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/immediate_care/immediate_medical_care.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/follow_up_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class FollowUpStep extends StatelessWidget {
  final FollowUpStepState model;

  const FollowUpStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        Provider.of<VisitReviewViewModel>(context);
    return ChangeNotifierProvider<FollowUpStepState>(
      create: (context) => FollowUpStepState(
        visitReviewViewModel: visitReviewViewModel,
      ),
      child: Consumer<FollowUpStepState>(
        builder: (_, model, __) => FollowUpStep(
          model: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (model.visitReviewViewModel.diagnosisOptions != null)
      return KeyboardDismisser(
        gestures: [GestureType.onTap],
        child: SwipeGestureRecognizer(
          onSwipeLeft: () {
            if (model.minimumRequiredFieldsFilledOut && model.editedStep) {
              model.editedStep = false;
              AppUtil()
                  .showFlushBar("Press save to save your changes", context);
            }
            model.visitReviewViewModel.incrementIndex();
          },
          onSwipeRight: () {
            if (model.minimumRequiredFieldsFilledOut && model.editedStep) {
              model.editedStep = false;
              AppUtil()
                  .showFlushBar("Press save to save your changes", context);
            }
            model.visitReviewViewModel.decrementIndex();
          },
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
                        "How would you like to follow up with this patient?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: RadioButtonGroup(
                        labelStyle: Theme.of(context).textTheme.bodyText1,
                        labels: FollowUpSteps.followUpSteps,
                        picked: model.followUp,
                        onSelected: (String selected) async {
                          model.updateFollowUpStepWith(followUp: selected);
                          if (selected == FollowUpSteps.Emergency) {
                            String result = await ImmediateMedicalCare.show(
                              context: context,
                              documentation: model.documentation,
                              patientUser: model
                                  .visitReviewViewModel.consult.patientUser,
                            );
                            model.updateFollowUpStepWith(documentation: result);
                          }
                        },
                      ),
                    ),
                    if (model.followUp == FollowUpSteps.ViaMedicall ||
                        model.followUp == FollowUpSteps.InPerson)
                      ..._buildDurationItem(context),
                    if (model.followUp == FollowUpSteps.Emergency)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 12, 24, 0),
                        child: SignInButton(
                            text: "Edit Immediate Care Documentation",
                            color: Colors.blue,
                            textColor: Colors.white,
                            height: 24,
                            onPressed: () async {
                              String result = await ImmediateMedicalCare.show(
                                context: context,
                                documentation: model.documentation,
                                patientUser: model
                                    .visitReviewViewModel.consult.patientUser,
                              );
                              model.updateFollowUpStepWith(
                                  documentation: result);
                            }),
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: ContinueButton(
                        title: "Save and Continue",
                        width: width,
                        onTap: this.model.minimumRequiredFieldsFilledOut
                            ? () async {
                                model.visitReviewViewModel
                                    .saveFollowUpToFirestore(model);
                                model.visitReviewViewModel.incrementIndex();
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
    return EmptyDiagnosis(model: model.visitReviewViewModel);
  }

  List<Widget> _buildDurationItem(BuildContext context) {
    String question = model.followUp == FollowUpSteps.ViaMedicall
        ? "What should be the estimated duration for the follow-up Medicall visit?"
        : "What should be the estimated duration for the follow-up in-person visit?";
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Text(
          question,
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
          textCapitalization: TextCapitalization.sentences,
          initialValue: model.getInitialValueForFollowUp,
          autocorrect: true,
          keyboardType: TextInputType.text,
          onChanged: (String text) =>
              model.updateFollowUpStepWith(duration: text),
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
            labelText: "Duration",
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
