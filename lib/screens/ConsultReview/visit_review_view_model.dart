import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/diagnosis_step_state.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/educational_step_state.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/exam_step_state.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/follow_up_step_state.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/patient_note_step_state.dart';
import 'package:Medicall/screens/ConsultReview/StepsViewModels/treatment_note_step_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

// Properties
abstract class VisitReviewVMProperties {
  static String get diagnosisStep => 'diagnosis_step';
  static String get examStep => 'exam_step';
  static String get treatmentStep => 'treatment_step';
  static String get followUpStep => 'follow_up_step';
  static String get educationalContent => 'educational_content';
  static String get patientNote => 'patient_note';
  static String get visitReview => 'root_screen'; //i.e root
}

// Properties
abstract class VisitReviewSteps {
  static const TotalSteps = 6;

  static const DiagnosisStep = 0;
  static const ExamStep = 1;
  static const TreatmentStep = 2;
  static const FollowUpStep = 3;
  static const EducationalContentStep = 4;
  static const PatientNote = 5;
}

class VisitReviewViewModel extends PropertyChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final ConsultReviewOptions consultReviewOptions;
  final Consult consult;
  DiagnosisOptions diagnosisOptions;
  VisitReviewData visitReviewData;

  int currentStep = VisitReviewSteps.DiagnosisStep;

  //used to de-clutter this view model, but they do not update listeners themselves
  final DiagnosisStepState diagnosisStepState = DiagnosisStepState();
  final EducationalStepState educationalStepState = EducationalStepState();
  final ExamStepState examStepState = ExamStepState();
  final FollowUpStepState followUpStepState = FollowUpStepState();
  final PatientNoteStepState patientNoteStepState = PatientNoteStepState();
  final TreatmentNoteStepState treatmentNoteStepState =
      TreatmentNoteStepState();

  VisitReviewViewModel({
    @required this.firestoreDatabase,
    @required this.consult,
    @required this.consultReviewOptions,
    @required this.visitReviewData,
  });

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
    } else if (index == VisitReviewSteps.PatientNote) {
      return "Patient Note";
    } else {
      return "Error";
    }
  }

  void incrementIndex() {
    this.currentStep = this.currentStep == VisitReviewSteps.TotalSteps - 1
        ? this.currentStep
        : this.currentStep + 1;
    notifyListeners(VisitReviewVMProperties.visitReview);
  }

  void decrementIndex() {
    this.currentStep = this.currentStep == VisitReviewSteps.DiagnosisStep
        ? this.currentStep
        : this.currentStep - 1;
    notifyListeners(VisitReviewVMProperties.visitReview);
  }

  void updateIndex(int index) {
    this.currentStep = index;
    notifyListeners(VisitReviewVMProperties.visitReview);
  }

  Future<void> updateDiagnosis(int selectedItemIndex) async {
    updateDiagnosisStepWith(selectedItemIndex: selectedItemIndex);
    this.diagnosisOptions =
        await firestoreDatabase.consultReviewDiagnosisOptions(
            symptomName: "Hairloss",
            diagnosis: this.diagnosisStepState.diagnosis);
  }

  void updateDiagnosisStepWith({
    int selectedItemIndex,
    bool includeDDX,
    String ddxOption,
  }) {
    this.diagnosisStepState.selectedItemIndex =
        selectedItemIndex ?? this.diagnosisStepState.selectedItemIndex;
    this.diagnosisStepState.includeDDX =
        includeDDX ?? this.diagnosisStepState.includeDDX;
    this.diagnosisStepState.ddxOption =
        ddxOption ?? this.diagnosisStepState.ddxOption;
    this.diagnosisStepState.diagnosis = this
        .consultReviewOptions
        .diagnosisList[this.diagnosisStepState.selectedItemIndex];

    notifyListeners(VisitReviewVMProperties.diagnosisStep);
  }

  void updateExamStepWith({
    List<String> selectedExamOptions,
    Map<String, String> locationMap,
  }) {
    this.examStepState.selectedExamOptions =
        selectedExamOptions ?? this.examStepState.selectedExamOptions;
    int index = this
        .examStepState
        .examLocations
        .indexWhere((element) => element.containsKey(locationMap.keys.first));
    if (index > -1) {
      this.examStepState.examLocations[index] = locationMap;
    } else {
      if (locationMap != null) {
        this.examStepState.examLocations.add(locationMap);
      }
    }
    notifyListeners(VisitReviewVMProperties.examStep);
  }

  void updateTreatmentStepWith({
    TreatmentOptions selectedTreatment,
  }) {
    if (this
            .treatmentNoteStepState
            .selectedTreatmentOptions
            .where((element) =>
                element.medicationName == selectedTreatment.medicationName)
            .toList()
            .length ==
        0) {
      this
          .treatmentNoteStepState
          .selectedTreatmentOptions
          .add(selectedTreatment);
    } else {
      int index = this
          .treatmentNoteStepState
          .selectedTreatmentOptions
          .indexWhere((element) =>
              element.medicationName == selectedTreatment.medicationName);
      if (index > -1) {
        this.treatmentNoteStepState.selectedTreatmentOptions[index] =
            selectedTreatment;
      }
    }
    notifyListeners(VisitReviewVMProperties.treatmentStep);
  }

  void deselectTreatmentStep(
    TreatmentOptions selectedTreatment,
  ) {
    this.treatmentNoteStepState.selectedTreatmentOptions.removeWhere(
          (element) =>
              element.medicationName == selectedTreatment.medicationName,
        );
    notifyListeners(VisitReviewVMProperties.treatmentStep);
  }

  void updateFollowUpStepWith({
    String followUp,
    String documentation,
    String duration,
  }) {
    this.followUpStepState.followUp =
        followUp ?? this.followUpStepState.followUp;
    this.followUpStepState.documentation =
        documentation ?? this.followUpStepState.documentation;
    this.followUpStepState.duration =
        duration ?? this.followUpStepState.duration;
    notifyListeners(VisitReviewVMProperties.followUpStep);
  }

  void updateEducationalInformation({
    List<String> selectedEducationalOptions,
  }) {
    this.educationalStepState.selectedEducationalOptions =
        selectedEducationalOptions ??
            this.educationalStepState.selectedEducationalOptions;
    notifyListeners(VisitReviewVMProperties.educationalContent);
  }

  void updatePatientNoteStepWith({
    String patientNote,
  }) {
    this.patientNoteStepState.patientNote =
        patientNote ?? this.patientNoteStepState.patientNote;
    notifyListeners(VisitReviewVMProperties.patientNote);
  }
}
