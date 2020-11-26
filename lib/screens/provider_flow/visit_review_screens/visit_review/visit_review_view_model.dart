import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/progress_timeline.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/diagnosis_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/educational_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/exam_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/follow_up_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/treatment_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/video_to_patient_step_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Properties
abstract class VisitReviewSteps {
  static const TotalSteps = 7;

  static const DiagnosisStep = 0;
  static const ExamStep = 1;
  static const TreatmentStep = 2;
  static const FollowUpStep = 3;
  static const EducationalContentStep = 4;
  static const PatientNoteStep = 5;
  static const PatientVideoStep = 6;
}

class VisitReviewViewModel extends ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final ConsultReviewOptions consultReviewOptions;
  final Consult consult;
  DiagnosisOptions diagnosisOptions;
  VisitReviewData visitReviewData;
  VisitReviewStatus visitReviewStatus;

  int currentStep = VisitReviewSteps.DiagnosisStep;

  List<int> completedSteps = [];

  PatientNoteStepState patientNoteStepState;

  ProgressTimeline screenProgress;

  List<SingleState> allStages = [
    SingleState(stateTitle: "Diagnosis"),
    SingleState(stateTitle: "Exam"),
    SingleState(stateTitle: "Treatment"),
    SingleState(stateTitle: "Follow Up"),
    SingleState(stateTitle: "Educational"),
    SingleState(stateTitle: "Patient Note"),
    SingleState(stateTitle: "Video Note"),
  ];

  VisitReviewViewModel({
    @required this.firestoreDatabase,
    @required this.consult,
    @required this.consultReviewOptions,
    @required this.visitReviewData,
    this.diagnosisOptions,
  });

  void setVisitReviewStatus(VisitReviewStatus visitReviewStatus) {
    this.visitReviewStatus = visitReviewStatus;
  }

  void setProgressTimeline() {
    screenProgress = new ProgressTimeline(
      height: 75,
      states: allStages,
      connectorColor: Color(0xff90024C), //no access to context, so manual
      iconSize: 35,
      connectorWidth: 2.0,
      onTap: (index) => this.updateIndex(index),
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
  }

  String getCustomStepText(int index) {
    if (index == VisitReviewSteps.DiagnosisStep) {
      return "Diagnosis";
    } else if (index == VisitReviewSteps.ExamStep) {
      return "Exam";
    } else if (index == VisitReviewSteps.TreatmentStep) {
      return "Treatment";
    } else if (index == VisitReviewSteps.FollowUpStep) {
      return "Follow Up";
    } else if (index == VisitReviewSteps.EducationalContentStep) {
      return "Educational";
    } else if (index == VisitReviewSteps.PatientNoteStep) {
      return "Patient Note";
    } else if (index == VisitReviewSteps.PatientVideoStep) {
      return "Video Note";
    } else {
      return "Error";
    }
  }

  void addCompletedStep({@required int step, @required bool setState}) {
    if (!this.completedSteps.contains(step)) {
      this.completedSteps.add(step);
      this
          .screenProgress
          .completeStep(singleState: allStages[step], setState: setState);
    }
  }

  void unCompleteStep({@required int step, @required bool setState}) {
    if (this.completedSteps.contains(step)) {
      this.completedSteps.remove(step);
      this
          .screenProgress
          .unCompleteStep(singleState: allStages[step], setState: setState);
    }
  }

  Future<void> saveDiagnosisToFirestore(DiagnosisStepState model) async {
    this.diagnosisOptions = model.diagnosisOptions;
    this.visitReviewData.diagnosis = model.diagnosis;
    this.visitReviewData.includeDDX = model.includeDDX;
    this.visitReviewData.ddxOptions = model.selectedDDXOptions;
    this.visitReviewData.ddxOtherOption = model.ddxOtherOption;
    this.visitReviewData.otherDiagnosis = model.otherDiagnosis;

    await firestoreDatabase.saveVisitReview(
      consultId: this.consult.uid,
      visitReviewData: this.visitReviewData,
      step: VisitReviewSteps.DiagnosisStep,
    );

    addCompletedStep(step: VisitReviewSteps.DiagnosisStep, setState: true);
    checkIfCompleted();
    notifyListeners();
  }

  Future<void> saveExamToFirestore(ExamStepState model) async {
    this.visitReviewData.examLocations = model.examLocationsForSerialization;

    await firestoreDatabase.saveVisitReview(
      consultId: this.consult.uid,
      visitReviewData: this.visitReviewData,
      step: VisitReviewSteps.ExamStep,
    );

    addCompletedStep(step: VisitReviewSteps.ExamStep, setState: true);
    checkIfCompleted();
  }

  Future<void> saveTreatmentToFirestore(TreatmentNoteStepState model) async {
    this.visitReviewData.treatmentOptions = model.selectedTreatmentOptions;

    await firestoreDatabase.saveVisitReview(
      consultId: this.consult.uid,
      visitReviewData: this.visitReviewData,
      step: VisitReviewSteps.TreatmentStep,
    );

    addCompletedStep(step: VisitReviewSteps.TreatmentStep, setState: true);
    checkIfCompleted();
  }

  Future<void> saveFollowUpToFirestore(FollowUpStepState model) async {
    this.visitReviewData.followUp = model.followUpMap;

    await firestoreDatabase.saveVisitReview(
      consultId: this.consult.uid,
      visitReviewData: this.visitReviewData,
      step: VisitReviewSteps.FollowUpStep,
    );

    addCompletedStep(step: VisitReviewSteps.FollowUpStep, setState: true);
    checkIfCompleted();
  }

  Future<void> saveEducationalToFirestore(EducationalStepState model) async {
    this.visitReviewData.educationalOptions =
        model.selectedEducationalOptions.map((option) {
      var link = "";
      if (option == "Other") {
        link = model.otherEducationalOption;
      } else {
        link = this
            .diagnosisOptions
            .educationalContent
            .where((e) => e.containsKey(option))
            .toList()
            .first
            .values
            .first;
      }

      return {option: link};
    }).toList();

    await firestoreDatabase.saveVisitReview(
      consultId: this.consult.uid,
      visitReviewData: this.visitReviewData,
      step: VisitReviewSteps.EducationalContentStep,
    );

    addCompletedStep(
        step: VisitReviewSteps.EducationalContentStep, setState: true);
    checkIfCompleted();
  }

  Future<void> savePatientNoteToFirestore(PatientNoteStepState model) async {
    await firestoreDatabase.saveVisitReview(
        consultId: this.consult.uid, visitReviewData: this.visitReviewData);

    addCompletedStep(step: VisitReviewSteps.PatientNoteStep, setState: true);
    checkIfCompleted();
    notifyListeners();
  }

  Future<void> saveVideoNoteToFirestore(VideoToPatientStepState model) async {
    this.visitReviewData.videoNoteURL = model.videoURL;

    await firestoreDatabase.saveVisitReview(
      consultId: this.consult.uid,
      visitReviewData: this.visitReviewData,
    );

    addCompletedStep(step: VisitReviewSteps.PatientVideoStep, setState: true);
    checkIfCompleted();
    notifyListeners();
  }

  void checkIfCompleted() async {
    if (this.completedSteps.length == 6 &&
        this.consult.state != ConsultStatus.Completed) {
      this.consult.state = ConsultStatus.Completed;
      await firestoreDatabase.saveConsult(
          consultId: this.consult.uid, consult: this.consult);
      this.visitReviewStatus.updateStatus("All required steps completed!");
    }
  }

  void incrementIndex() {
    this.currentStep = this.currentStep == VisitReviewSteps.TotalSteps - 1
        ? this.currentStep
        : this.currentStep + 1;
    this.screenProgress.gotoNextStage();
    notifyListeners();
  }

  void decrementIndex() {
    this.currentStep = this.currentStep == VisitReviewSteps.DiagnosisStep
        ? this.currentStep
        : this.currentStep - 1;
    this.screenProgress.gotoPreviousStage();
    notifyListeners();
  }

  void updateIndex(int index) {
    this.currentStep = index;
    notifyListeners();
  }
}

mixin VisitReviewStatus {
  void updateStatus(String msg);
}
