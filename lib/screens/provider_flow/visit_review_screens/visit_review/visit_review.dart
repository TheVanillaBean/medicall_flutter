import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/diagnosis_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/educational_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/exam_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/follow_up_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/patient_note_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/treatment_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_widgets/video_to_patient_step.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/screens/shared/visit_information/consult_photos.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisitReview extends StatefulWidget {
  final VisitReviewViewModel model;

  const VisitReview({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
    ConsultReviewOptions consultReviewOptions,
    VisitReviewData visitReviewData,
    DiagnosisOptions diagnosisOptions,
  ) {
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context);
    return ChangeNotifierProvider<VisitReviewViewModel>(
      create: (context) => VisitReviewViewModel(
        firestoreDatabase: firestoreDatabase,
        consult: consult,
        consultReviewOptions: consultReviewOptions,
        visitReviewData: visitReviewData,
        diagnosisOptions: diagnosisOptions,
      ),
      child: Consumer<VisitReviewViewModel>(
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
    DiagnosisOptions diagnosisOptions,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.visitReview,
      arguments: {
        'consult': consult,
        'consultReviewOptions': consultReviewOptions,
        'visitReviewData': visitReviewData,
        'diagnosisOptions': diagnosisOptions,
      },
    );
  }

  @override
  _VisitReviewState createState() => _VisitReviewState();
}

class _VisitReviewState extends State<VisitReview> with VisitReviewStatus {
  @override
  void initState() {
    widget.model.setProgressTimeline();
    super.initState();
  }

  Future<bool> _onWillPop() async {
    bool didPressYes = false;
    if (widget.model.consult.state != ConsultStatus.Completed) {
      didPressYes = await PlatformAlertDialog(
        title: "Cancel Review?",
        content: "Are you sure you want to exit this screen?",
        defaultActionText: "Yes, cancel",
        cancelActionText: "No",
      ).show(context);
    } else {
      didPressYes = await PlatformAlertDialog(
        title: "Exit Screen?",
        content:
            "This visit is completed. Do you want to exit this screen now?",
        defaultActionText: "Yes, exit",
        cancelActionText: "No",
      ).show(context);
    }

    if (didPressYes) {
      Navigator.of(context).pop();
      return false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.model.setVisitReviewStatus(this);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: widget.model.getCustomStepText(widget.model.currentStep),
          theme: Theme.of(context),
          onPressed: () => Navigator.maybePop(context),
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
              child: widget.model.screenProgress,
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
                  TreatmentStep.create(context),
                  FollowUpStep.create(context),
                  EducationalContentStep.create(context),
                  PatientNoteStep.create(context),
                  VideoToPatientStep.create(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void updateStatus(String msg) {
    AppUtil().showFlushBar(msg, context);
  }
}
