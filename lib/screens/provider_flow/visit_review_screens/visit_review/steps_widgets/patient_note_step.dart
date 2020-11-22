import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/edit_note/edit_note_section.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class PatientNoteStep extends StatelessWidget {
  final PatientNoteStepState model;

  const PatientNoteStep({@required this.model});

  static Widget create(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        Provider.of<VisitReviewViewModel>(context);
    return ChangeNotifierProvider<PatientNoteStepState>(
      create: (context) => PatientNoteStepState(
        visitReviewViewModel: visitReviewViewModel,
      ),
      child: Consumer<PatientNoteStepState>(
        builder: (_, model, __) => PatientNoteStep(
          model: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (model.initFromDiagnosis) {
      model.initFromDiagnosisOptions();
    }
    if (model.visitReviewViewModel.diagnosisOptions != null)
      return KeyboardDismisser(
        gestures: [
          GestureType.onTap
        ], //onVerticalDrag not set because of weird behavior
        child: SwipeGestureRecognizer(
          onSwipeLeft: () => model.visitReviewViewModel.incrementIndex(),
          onSwipeRight: () => model.visitReviewViewModel.decrementIndex(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ..._buildSection(
                        context: context,
                        section: PatientNoteSection.Introduction,
                        title: "Introduction: (Required)",
                        body: model.introductionBody,
                        width: width,
                        height: height,
                        checked: model.introductionCheckbox,
                        onChanged: (newValue) async => await model.updateWith(
                            introductionCheckbox: newValue),
                      ),
                      ..._buildSection(
                        context: context,
                        section: PatientNoteSection.UnderstandingDiagnosis,
                        title: "Understanding the diagnosis:",
                        body: model.understandingBody,
                        width: width,
                        height: height,
                        checked: model.understandingCheckbox,
                        onChanged: (newValue) async => await model.updateWith(
                            understandingCheckbox: newValue),
                      ),
                      ..._buildSection(
                        context: context,
                        section: PatientNoteSection.Counseling,
                        title: "Counseling:",
                        body: model.counselingBody,
                        width: width,
                        height: height,
                        checked: model.counselingCheckbox,
                        onChanged: (newValue) async => await model.updateWith(
                            counselingCheckbox: newValue),
                      ),
                      ..._buildSection(
                        context: context,
                        section: PatientNoteSection.Treatments,
                        title: "Treatments:",
                        body: model.treatmentBody,
                        width: width,
                        height: height,
                        checked: model.treatmentsCheckbox,
                        onChanged: (newValue) async => await model.updateWith(
                            treatmentsCheckbox: newValue),
                      ),
                      ..._buildSection(
                        context: context,
                        section: PatientNoteSection.FurtherTesting,
                        title: "Further Testing (optional):",
                        body: model.furtherTestingBody,
                        width: width,
                        height: height,
                        checked: model.furtherTestingCheckbox,
                        onChanged: (newValue) async => await model.updateWith(
                            furtherTestingCheckbox: newValue),
                      ),
                      ..._buildSection(
                        context: context,
                        section: PatientNoteSection.Conclusion,
                        title: "Conclusion:",
                        body: model.conclusionBody,
                        width: width,
                        height: height,
                        checked: model.conclusionCheckbox,
                        onChanged: (newValue) async => await model.updateWith(
                            conclusionCheckbox: newValue),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ContinueButton(
                          title: "Save and Continue",
                          width: width,
                          onTap: this.model.minimumRequiredFieldsFilledOut
                              ? () async {
                                  await model.saveSelectedSections();
                                  AppUtil().showFlushBar(
                                      "Successfully updated patient note",
                                      context);
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    return EmptyDiagnosis(model: model.visitReviewViewModel);
  }

  List<Widget> _buildSection({
    BuildContext context,
    PatientNoteSection section,
    String title,
    bool checked = false,
    String body,
    double width,
    double height,
    ValueChanged<bool> onChanged,
  }) {
    return [
      Row(
        children: [
          SizedBox(
            width: 18,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => onChanged(!checked),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      Text(
        body,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      SizedBox(height: 12),
      _buildSectionBtn(
        context: context,
        width: width,
        height: height,
        title: "Edit Section",
        section: section,
        enabled: checked,
      ),
    ];
  }

  Widget _buildSectionBtn({
    BuildContext context,
    PatientNoteSection section,
    double width,
    double height,
    String title,
    bool enabled,
  }) {
    return Container(
      width: width * .35,
      child: SizedBox(
        height: 30,
        child: RaisedButton(
          elevation: 0,
          color: Theme.of(context).colorScheme.primary,
          disabledColor: Theme.of(context).disabledColor.withOpacity(.3),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: !enabled
              ? null
              : () async {
                  Map<String, String> editedNote = await EditNoteSection.show(
                    context: context,
                    section: section,
                    sectionTitle: title,
                    editedSection: model.getEditedSection(section),
                    templateSection: model.getTemplateSection(section),
                  );
                  if (editedNote != null) {
                    model.updateSection(section, editedNote);
                    await model.visitReviewViewModel
                        .savePatientNoteToFirestore(model);
                    model.checkForCompleted();
                  }
                },
        ),
      ),
    );
  }
}
