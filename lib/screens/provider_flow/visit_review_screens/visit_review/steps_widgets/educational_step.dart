import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
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
                        activeColor: Theme.of(context).colorScheme.primary,
                        labels: model.diagnosisOptions.educationalContent
                            .map((e) => e.keys.first.toString())
                            .toList(),
                        onSelected: (List<String> checked) =>
                            model.updateEducationalInformation(
                                selectedEducationalOptions: checked),
                        checked: model
                            .educationalStepState.selectedEducationalOptions,
                      ),
                    ),
                    if (model.educationalStepState.otherSelected)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue:
                              model.educationalStepState.otherEducationalOption,
                          autocorrect: true,
                          keyboardType: TextInputType.text,
                          onChanged: (String text) =>
                              model.updateEducationalInformation(
                                  otherEducationalOption: text),
                          style: Theme.of(context).textTheme.bodyText2,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(90),
                            ),
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(100, 100, 100, 1),
                            ),
                            filled: true,
                            fillColor: Colors.grey.withAlpha(20),
                            labelText: "Enter Custom Education Info",
                            hintText: 'Optional',
                          ),
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
    return EmptyDiagnosis(model: model);
  }
}
