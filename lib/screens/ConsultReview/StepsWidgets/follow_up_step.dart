import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/continue_button.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/ConsultReview/ReusableWidgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/follow_up_step_state.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:Medicall/screens/Questions/ImmediateMedicalCare/immediate_medical_care.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class FollowUpStep extends StatefulWidget {
  @override
  _FollowUpStepState createState() => _FollowUpStepState();
}

class _FollowUpStepState extends State<FollowUpStep> {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.followUpStep],
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
                        "How would you like to follow up with this patient?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: width * 0.8,
                      child: RadioButtonGroup(
                        labels: FollowUpSteps.followUpSteps,
                        picked: model.followUpStepState.followUp,
                        onSelected: (String selected) {
                          model.updateFollowUpStepWith(followUp: selected);
                          if (selected == FollowUpSteps.Emergency) {
                            ImmediateMedicalCare.show(
                              context: context,
                              visitReviewViewModel: model,
                              documentation:
                                  model.followUpStepState.documentation,
                            );
                          }
                        },
                      ),
                    ),
                    if (model.followUpStepState.followUp ==
                            FollowUpSteps.ViaMedicall ||
                        model.followUpStepState.followUp ==
                            FollowUpSteps.InPerson)
                      ..._buildDurationItem(model),
                    if (model.followUpStepState.followUp ==
                        FollowUpSteps.Emergency)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 12, 24, 0),
                        child: SignInButton(
                          text: "Edit Immediate Care Documentation",
                          color: Colors.blue,
                          textColor: Colors.white,
                          height: 24,
                          onPressed: () => ImmediateMedicalCare.show(
                            context: context,
                            visitReviewViewModel: model,
                            documentation:
                                model.followUpStepState.documentation,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    ContinueButton(
                      width: width,
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

  List<Widget> _buildDurationItem(VisitReviewViewModel model) {
    String question = model.followUpStepState.followUp ==
            FollowUpSteps.ViaMedicall
        ? "What should be the estimated duration for the follow-up Medicall visit?"
        : "What should be the estimated duration for the follow-up in-person visit?";
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
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
        child: TextField(
          autocorrect: false,
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
            prefixIcon: Icon(
              Icons.text_fields,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
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
