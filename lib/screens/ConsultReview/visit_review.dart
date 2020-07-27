import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/diagnosis_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/educational_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/exam_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/follow_up_step.dart';
import 'package:Medicall/screens/ConsultReview/StepsWidgets/patient_note_step.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'StepsWidgets/treatment_step.dart';

class VisitReview extends StatefulWidget {
  final VisitReviewViewModel model;

  const VisitReview({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
    ConsultReviewOptions consultReviewOptions,
    VisitReviewData visitReviewData,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return PropertyChangeProvider<VisitReviewViewModel>(
      value: VisitReviewViewModel(
        firestoreDatabase: firestoreDatabase,
        consult: consult,
        consultReviewOptions: consultReviewOptions,
        visitReviewData: visitReviewData,
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
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitReview,
      arguments: {
        'consult': consult,
        'consultReviewOptions': consultReviewOptions,
        'visitReviewData': visitReviewData,
      },
    );
  }

  @override
  _VisitReviewState createState() => _VisitReviewState();
}

class _VisitReviewState extends State<VisitReview> with VisitReviewStatus {
  @override
  Widget build(BuildContext context) {
    widget.model.visitReviewStatus = this;
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
          widget.model.getCustomStepText(widget.model.currentStep),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 8,
            child: IndexedStack(
              index: widget.model.currentStep,
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
                    currentStep: widget.model.currentStep,
                    size: 48,
                    roundedEdges: Radius.circular(25),
                    customStep: (index, color, size) => buildCustomStep(index),
                    onTap: (index) => () => widget.model.updateIndex(index),
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
      color: getColorForStep(stepIndex),
      child: Center(
        child: Text(
          widget.model.getCustomStepText(stepIndex),
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  MaterialColor getColorForStep(int stepIndex) {
    if (widget.model.completedSteps.contains(stepIndex)) {
      return Colors.blueGrey;
    }
    if (widget.model.currentStep == stepIndex) {
      return Colors.indigo;
    } else {
      return Colors.blue;
    }
  }

  @override
  void updateStatus(String msg) {
    AppUtil().showFlushBar(msg, context);
  }
}
