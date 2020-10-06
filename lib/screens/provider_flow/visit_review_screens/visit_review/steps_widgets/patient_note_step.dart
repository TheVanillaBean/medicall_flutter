import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/edit_note_section.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class PatientNoteStep extends StatefulWidget {
  @override
  _PatientNoteStepState createState() => _PatientNoteStepState();
}

class _PatientNoteStepState extends State<PatientNoteStep> {
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel model =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.patientNote],
    ).value;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (model.diagnosisOptions != null)
      return KeyboardDismisser(
        gestures: [
          GestureType.onTap
        ], //onVerticalDrag not set because of weird behavior
        child: SwipeGestureRecognizer(
          onSwipeLeft: () => model.incrementIndex(),
          onSwipeRight: () => model.decrementIndex(),
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
                        title: "Introduction:",
                        body: model.patientNoteStepState.sectionBody(
                          "Introduction:",
                          model.diagnosisOptions,
                        ),
                        width: width,
                        height: height,
                        model: model,
                        checked:
                            model.patientNoteStepState.introductionCheckbox ??
                                false,
                        onChanged: (newValue) => {
                          model.updatePatientNoteStepWith(
                            introductionCheckbox: newValue,
                          ),
                        },
                      ),
                      ..._buildSection(
                        title: "Understanding the diagnosis:",
                        body: model.patientNoteStepState.sectionBody(
                          "Understanding the diagnosis:",
                          model.diagnosisOptions,
                        ),
                        width: width,
                        height: height,
                        model: model,
                        checked:
                            model.patientNoteStepState.understandingCheckbox ??
                                false,
                        onChanged: (newValue) => {
                          model.updatePatientNoteStepWith(
                            understandingCheckbox: newValue,
                          ),
                        },
                      ),
                      ..._buildSection(
                        title: "Counseling:",
                        body: model.patientNoteStepState.sectionBody(
                          "Counseling:",
                          model.diagnosisOptions,
                        ),
                        width: width,
                        height: height,
                        model: model,
                        checked:
                            model.patientNoteStepState.counselingCheckbox ??
                                false,
                        onChanged: (newValue) => {
                          model.updatePatientNoteStepWith(
                            counselingCheckbox: newValue,
                          ),
                        },
                      ),
                      ..._buildSection(
                        title: "Treatments:",
                        body: model.patientNoteStepState.sectionBody(
                          "Treatments:",
                          model.diagnosisOptions,
                        ),
                        width: width,
                        height: height,
                        model: model,
                        checked:
                            model.patientNoteStepState.treatmentsCheckbox ??
                                false,
                        onChanged: (newValue) => {
                          model.updatePatientNoteStepWith(
                            treatmentsCheckbox: newValue,
                          ),
                        },
                      ),
                      ..._buildSection(
                        title: "Further Testing (optional):",
                        body: model.patientNoteStepState.sectionBody(
                          "Further Testing (optional):",
                          model.diagnosisOptions,
                        ),
                        width: width,
                        height: height,
                        model: model,
                        checked:
                            model.patientNoteStepState.furtherTestingCheckbox ??
                                false,
                        onChanged: (newValue) => {
                          model.updatePatientNoteStepWith(
                            furtherTestingCheckbox: newValue,
                          ),
                        },
                      ),
                      ..._buildSection(
                        title: "Other:",
                        body: "",
                        width: width,
                        height: height,
                        model: model,
                      ),
                      ..._buildSection(
                        title: "Conclusion:",
                        body: model.patientNoteStepState.sectionBody(
                          "Conclusion:",
                          model.diagnosisOptions,
                        ),
                        width: width,
                        height: height,
                        model: model,
                        checked:
                            model.patientNoteStepState.conclusionCheckbox ??
                                false,
                        onChanged: (newValue) => {
                          model.updatePatientNoteStepWith(
                            conclusionCheckbox: newValue,
                          ),
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ContinueButton(
                          width: width,
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
    return EmptyDiagnosis(model: model);
  }

  List<Widget> _buildSection({
    String title,
    bool checked = false,
    String body,
    double width,
    double height,
    ValueChanged<bool> onChanged,
    VisitReviewViewModel model,
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
          Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
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
        width: width,
        height: height,
        title: "Edit Section",
        section: title,
        model: model,
      ),
    ];
  }

  Widget _buildSectionBtn({
    double width,
    double height,
    String title,
    String section,
    VisitReviewViewModel model,
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
          onPressed: () {
            model.patientNoteStepState.setEditSectionNoteBody(
              section,
              model.diagnosisOptions,
            );
            EditNoteSection.show(
              context: context,
              visitReviewViewModel: model,
            );
          },
        ),
      ),
    );
  }
}
