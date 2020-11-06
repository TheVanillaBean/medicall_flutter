import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/diagnosis_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/educational_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/exam_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/follow_up_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/patient_note_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/treatment_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/screens/shared/visit_information/consult_photos.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:progress_timeline/progress_timeline.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

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
    await Navigator.of(context).pushReplacementNamed(
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
  ProgressTimeline screenProgress;

  List<SingleState> allStages = [
    SingleState(stateTitle: "Diagnosis"),
    SingleState(stateTitle: "Exam"),
    SingleState(stateTitle: "Treatment"),
    SingleState(stateTitle: "Follow Up"),
    SingleState(stateTitle: "Educational"),
    SingleState(stateTitle: "Textual Note"),
    SingleState(stateTitle: "Video Note"),
  ];

  @override
  void initState() {
    screenProgress = new ProgressTimeline(
      states: allStages,
      connectorColor: Color(0xff90024C), //no access to context, so manual
      iconSize: 35,
      connectorWidth: 2.0,
      checkedIcon: Icon(
        Icons.check_circle,
        color: Color(0xff90024C),
        size: 35,
      ),
      currentIcon: Icon(
        Icons.adjust,
        color: Color(0xff90024C),
        size: 35,
      ),
      failedIcon: Icon(
        Icons.highlight_off,
        color: Colors.redAccent,
        size: 35,
      ),
      uncheckedIcon: Icon(
        Icons.radio_button_unchecked,
        color: Color(0xff90024C),
        size: 35,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.model.setVisitReviewStatus(this);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () async {
                final didPressYes = await PlatformAlertDialog(
                  title: "Cancel Review?",
                  content: "Are you sure you want to cancel?",
                  defaultActionText: "Yes, cancel",
                  cancelActionText: "No",
                ).show(context);
                if (didPressYes) {
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          widget.model.getCustomStepText(widget.model.currentStep),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.photo_library,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              ConsultPhotos.show(
                context: context,
                consult: widget.model.consult,
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: screenProgress,
          ),
          Divider(
            height: 2,
          ),
          Expanded(
            child: IndexedStack(
              index: widget.model.currentStep,
              children: <Widget>[
                DiagnosisStep.create(context),
                ExamStep.create(context),
                TreatmentStep(),
                FollowUpStep(),
                EducationalContentStep(),
                PatientNoteStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void updateStatus(String msg) {
    AppUtil().showFlushBar(msg, context);
    if (widget.model.completedSteps.length == 6) {
      Navigator.of(context).popUntil(
        (ModalRoute.withName(Routes.visitOverview)),
      );
    }
  }
}
