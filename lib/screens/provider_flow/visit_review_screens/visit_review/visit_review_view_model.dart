import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_timeline/progress_timeline.dart';

// Properties
abstract class VisitReviewSteps {
  static const TotalSteps = 5;

  static const DiagnosisStep = 0;
  static const ExamStep = 1;
  static const TreatmentStep = 2;
  static const FollowUpStep = 3;
  static const EducationalContentStep = 4;
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

  bool continueBtnPressed = false;

  ScrollController scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  PatientNoteStepState patientNoteStepState = PatientNoteStepState();

  ProgressTimeline screenProgress;

  List<SingleState> allStages = [
    SingleState(stateTitle: "Diagnosis"),
    SingleState(stateTitle: "Exam"),
    SingleState(stateTitle: "Treatment"),
    SingleState(stateTitle: "Follow Up"),
    SingleState(stateTitle: "Educational"),
  ];

  void setProgressTimeline() {
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
  }

  VisitReviewViewModel({
    @required this.firestoreDatabase,
    @required this.consult,
    @required this.consultReviewOptions,
    @required this.visitReviewData,
  });

  void setVisitReviewStatus(VisitReviewStatus visitReviewStatus) {
    this.visitReviewStatus = visitReviewStatus;
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
    } else {
      return "Error";
    }
  }

  // bool get canContinue {
  //   if (currentStep == VisitReviewSteps.DiagnosisStep) {
  //     return this.diagnosisStepState.minimumRequiredFieldsFilledOut;
  //   } else if (currentStep == VisitReviewSteps.ExamStep) {
  //     return this.examStepState.minimumRequiredFieldsFilledOut;
  //   } else if (currentStep == VisitReviewSteps.TreatmentStep) {
  //     return this.treatmentNoteStepState.minimumRequiredFieldsFilledOut;
  //   } else if (currentStep == VisitReviewSteps.FollowUpStep) {
  //     return this.followUpStepState.minimumRequiredFieldsFilledOut;
  //   } else if (currentStep == VisitReviewSteps.EducationalContentStep) {
  //     return this.educationalStepState.minimumRequiredFieldsFilledOut;
  //   } else {
  //     return false;
  //   }
  // }
  //
  // void updateCompletedStepsList() {
  //   List<int> completedSteps = [];
  //   if (continueBtnPressed) {
  //     if (this.diagnosisStepState.minimumRequiredFieldsFilledOut) {
  //       completedSteps.add(VisitReviewSteps.DiagnosisStep);
  //     }
  //     if (this.examStepState.minimumRequiredFieldsFilledOut) {
  //       completedSteps.add(VisitReviewSteps.ExamStep);
  //     }
  //     if (this.treatmentNoteStepState.minimumRequiredFieldsFilledOut) {
  //       completedSteps.add(VisitReviewSteps.TreatmentStep);
  //     }
  //     if (this.followUpStepState.minimumRequiredFieldsFilledOut) {
  //       completedSteps.add(VisitReviewSteps.FollowUpStep);
  //     }
  //     if (this.educationalStepState.minimumRequiredFieldsFilledOut) {
  //       completedSteps.add(VisitReviewSteps.EducationalContentStep);
  //     }
  //     this.completedSteps = completedSteps;
  //   }
  // }
  //
  // void checkIfWorkSaved() {
  //   if (canContinue &&
  //       !continueBtnPressed &&
  //       !this.completedSteps.contains(this.currentStep)) {
  //     this
  //         .visitReviewStatus
  //         .updateStatus("Press continue to save your work for this step.");
  //   }
  // }
  //
  // Future<void> saveVisitReviewToFirestore() async {
  //   this.visitReviewData.diagnosis = this.diagnosisStepState.diagnosis;
  //   this.visitReviewData.includeDDX = this.diagnosisStepState.includeDDX;
  //   this.visitReviewData.ddxOptions =
  //       this.diagnosisStepState.selectedDDXOptions;
  //   this.visitReviewData.ddxOtherOption =
  //       this.diagnosisStepState.ddxOtherOption;
  //   this.visitReviewData.otherDiagnosis =
  //       this.diagnosisStepState.otherDiagnosis;
  //   this.visitReviewData.examLocations =
  //       this.examStepState.examLocationsForSerialization;
  //   this.visitReviewData.treatmentOptions =
  //       this.treatmentNoteStepState.selectedTreatmentOptions;
  //   this.visitReviewData.educationalOptions =
  //       this.educationalStepState.selectedEducationalOptions.map((option) {
  //     var link = "";
  //     if (option == "Other") {
  //       link = this.educationalStepState.otherEducationalOption;
  //     } else {
  //       link = this
  //           .diagnosisOptions
  //           .educationalContent
  //           .where((e) => e.containsKey(option))
  //           .toList()
  //           .first
  //           .values
  //           .first;
  //     }
  //
  //     return {option: link};
  //   }).toList();
  //
  //   this.visitReviewData.followUp = this.followUpStepState.followUpMap;
  //
  //   this.visitReviewData.patientNote =
  //       this.patientNoteStepState.patientTemplateNote;
  //
  //   await firestoreDatabase.saveVisitReview(
  //       consultId: this.consult.uid, visitReviewData: this.visitReviewData);
  //
  //   if (this.completedSteps.length == 6) {
  //     this.consult.state = ConsultStatus.Completed;
  //     await firestoreDatabase.saveConsult(
  //         consultId: consult.uid, consult: consult);
  //     this.visitReviewStatus.updateStatus("All steps completed!");
  //   }
  // }

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
