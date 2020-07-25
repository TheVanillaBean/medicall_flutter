import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/diagnosis_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/educational_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/exam_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/follow_up_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/patient_note_step.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'StepsWidgets/treatment_step.dart';

class VisitReview extends StatelessWidget {
  final VisitReviewViewModel model;

  const VisitReview({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
    ConsultReviewOptions consultReviewOptions,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return PropertyChangeProvider<VisitReviewViewModel>(
      value: VisitReviewViewModel(
        firestoreDatabase: firestoreDatabase,
        consult: consult,
        consultReviewOptions: consultReviewOptions,
      ),
      child: PropertyChangeConsumer<VisitReviewViewModel>(
        properties: [VisitReviewVMProperties.visitReview],
        builder: (_, model, __) => VisitReview(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    Consult consult,
    ConsultReviewOptions consultReviewOptions,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitReview,
      arguments: {
        'consult': consult,
        'consultReviewOptions': consultReviewOptions,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          model.getCustomStepText(model.currentStep),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 8,
            child: IndexedStack(
              index: model.currentStep,
              children: <Widget>[
                DiagnosisStep(),
                ExamStep(),
                TreatmentStep(),
                FollowUpStep(),
                EducationalContentStep(),
                PatientNoteStep(),
              ],
            ),
          ),
          Divider(
            height: 2,
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width * 1.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: StepProgressIndicator(
                    direction: Axis.horizontal,
                    totalSteps: VisitReviewSteps.TotalSteps,
                    currentStep: model.currentStep,
                    size: 48,
                    roundedEdges: Radius.circular(25),
                    customStep: (index, color, size) => buildCustomStep(index),
                    onTap: (index) => () => model.updateIndex(index),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCustomStep(int stepIndex) {
    return Container(
      color: model.currentStep == stepIndex ? Colors.indigo : Colors.blue,
      child: Center(
        child: Text(
          model.getCustomStepText(stepIndex),
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }
}
