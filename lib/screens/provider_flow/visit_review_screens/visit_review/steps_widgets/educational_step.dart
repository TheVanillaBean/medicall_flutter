import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/educational_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class EducationalContentStep extends StatelessWidget {
  final EducationalStepState model;

  const EducationalContentStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        Provider.of<VisitReviewViewModel>(context);
    return ChangeNotifierProvider<EducationalStepState>(
      create: (context) => EducationalStepState(
        visitReviewViewModel: visitReviewViewModel,
      ),
      child: Consumer<EducationalStepState>(
        builder: (_, model, __) => EducationalContentStep(
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
                        labels: model.visitReviewViewModel.diagnosisOptions
                            .educationalContent
                            .map((e) => e.keys.first.toString())
                            .toList(),
                        onSelected: (List<String> checked) =>
                            model.updateEducationalInformation(
                                selectedEducationalOptions: checked),
                        checked: model.selectedEducationalOptions,
                      ),
                    ),
                    if (model.otherSelected)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          initialValue: model.otherEducationalOption,
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
                        title: "Save and Continue",
                        width: width,
                        onTap: this.model.minimumRequiredFieldsFilledOut
                            ? () async {
                                model.visitReviewViewModel
                                    .saveEducationalToFirestore(model);
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
}
