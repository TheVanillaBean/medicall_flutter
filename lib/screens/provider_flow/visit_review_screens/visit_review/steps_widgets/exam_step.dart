import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/exam_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class ExamStep extends StatelessWidget {
  final ExamStepState model;

  const ExamStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        Provider.of<VisitReviewViewModel>(context);
    return ChangeNotifierProvider<ExamStepState>(
      create: (context) => ExamStepState(
        visitReviewViewModel: visitReviewViewModel,
      ),
      child: Consumer<ExamStepState>(
        builder: (_, model, __) => ExamStep(
          model: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (this.model.visitReviewViewModel.diagnosisOptions != null)
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
                        labels: this
                            .model
                            .visitReviewViewModel
                            .diagnosisOptions
                            .exam,
                        onSelected: (List<String> checked) => this
                            .model
                            .updateExamStepWith(selectedExamOptions: checked),
                        checked: this.model.selectedExamOptions,
                      ),
                    ),
                    if (this.model.selectedExamOptions.length > 0)
                      for (String examOption in this.model.selectedExamOptions)
                        ..._buildLocationItem(
                          context,
                          examOption,
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
                                    .saveExamToFirestore(model);
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
    return EmptyDiagnosis(model: this.model.visitReviewViewModel);
  }

  List<Widget> _buildLocationItem(
    BuildContext context,
    String examOption,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          this.model.locationQuestion(examOption),
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
          initialValue: this.model.getExamLocation(examOption),
          autocorrect: true,
          keyboardType: TextInputType.text,
          onChanged: (String text) =>
              this.model.updateExamStepWith(locationMap: {examOption: text}),
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
            ),
            hintStyle: TextStyle(
              color: Color.fromRGBO(100, 100, 100, 1),
            ),
            filled: true,
            fillColor: Colors.grey.withAlpha(20),
            labelText: examOption.toLowerCase() == "other"
                ? "Custom Examination"
                : "Location",
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
