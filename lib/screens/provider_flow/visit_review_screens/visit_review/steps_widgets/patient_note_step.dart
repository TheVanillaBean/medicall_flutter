import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/empty_diagnosis_widget.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/swipe_gesture_recognizer.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/material.dart';
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
    if (model.diagnosisOptions != null) {
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
                fillOverscroll: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Message",
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
                        maxLines: null,
                        scrollPhysics: NeverScrollableScrollPhysics(),
                        initialValue:
                            model.patientNoteStepState.getPatientNoteTemplate(
                          model.consult.patientUser.fullName,
                          "${model.consult.providerUser.fullName}, ${model.consult.providerUser.professionalTitle}",
                          model.diagnosisOptions.patientNoteTemplate,
                        ),
                        autocorrect: true,
                        keyboardType: TextInputType.multiline,
                        onChanged: (String text) =>
                            model.updatePatientNoteStepWith(patientNote: text),
                        style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
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
                          labelText: "Patient Note",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
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