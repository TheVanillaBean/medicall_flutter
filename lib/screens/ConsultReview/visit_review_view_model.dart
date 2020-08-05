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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

// Properties
abstract class VisitReviewVMProperties {
  static String get continueBtn => 'continue_btn';
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
  VisitReviewStatus visitReviewStatus;

  int currentStep = VisitReviewSteps.DiagnosisStep;

  List<int> completedSteps = [];

  bool continueBtnPressed = false;

  ScrollController scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

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
  }) {
    this.setDiagnosisFromPrevData();
    this.setExamFromPrevData();
    this.setTreatmentFromPrevData();
    this.setFollowUpFromPrevData();
    this.setPatientNoteFromPrevData();
    this.setEducationalInfoFromPrevData();
  }

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
    } else if (index == VisitReviewSteps.PatientNote) {
      return "Patient Note";
    } else {
      return "Error";
    }
  }

  bool get canContinue {
    if (currentStep == VisitReviewSteps.DiagnosisStep) {
      return this.diagnosisStepState.minimumRequiredFieldsFilledOut;
    } else if (currentStep == VisitReviewSteps.ExamStep) {
      return this.examStepState.minimumRequiredFieldsFilledOut;
    } else if (currentStep == VisitReviewSteps.TreatmentStep) {
      return this.treatmentNoteStepState.minimumRequiredFieldsFilledOut;
    } else if (currentStep == VisitReviewSteps.FollowUpStep) {
      return this.followUpStepState.minimumRequiredFieldsFilledOut;
    } else if (currentStep == VisitReviewSteps.EducationalContentStep) {
      return this.educationalStepState.minimumRequiredFieldsFilledOut;
    } else if (currentStep == VisitReviewSteps.PatientNote) {
      return this.patientNoteStepState.minimumRequiredFieldsFilledOut;
    } else {
      return false;
    }
  }

  void updateCompletedStepsList() {
    List<int> completedSteps = [];
    if (continueBtnPressed) {
      if (this.diagnosisStepState.minimumRequiredFieldsFilledOut) {
        completedSteps.add(VisitReviewSteps.DiagnosisStep);
      }
      if (this.examStepState.minimumRequiredFieldsFilledOut) {
        completedSteps.add(VisitReviewSteps.ExamStep);
      }
      if (this.treatmentNoteStepState.minimumRequiredFieldsFilledOut) {
        completedSteps.add(VisitReviewSteps.TreatmentStep);
      }
      if (this.followUpStepState.minimumRequiredFieldsFilledOut) {
        completedSteps.add(VisitReviewSteps.FollowUpStep);
      }
      if (this.educationalStepState.minimumRequiredFieldsFilledOut) {
        completedSteps.add(VisitReviewSteps.EducationalContentStep);
      }
      if (this.currentStep == VisitReviewSteps.PatientNote &&
          this.patientNoteStepState.minimumRequiredFieldsFilledOut) {
        int index = completedSteps.indexOf(VisitReviewSteps.PatientNote);
        if (index > 0) {
          completedSteps.insert(index, VisitReviewSteps.PatientNote);
        } else {
          completedSteps.add(VisitReviewSteps.PatientNote);
        }
      }
      this.completedSteps = completedSteps;
    }
  }

  void checkIfWorkSaved() {
    if (canContinue &&
        !continueBtnPressed &&
        !this.completedSteps.contains(this.currentStep)) {
      this
          .visitReviewStatus
          .updateStatus("Press continue to save your work for this step.");
    }
  }

  Future<void> saveVisitReviewToFirestore() async {
    this.visitReviewData.diagnosis = this.diagnosisStepState.diagnosis;
    this.visitReviewData.includeDDX = this.diagnosisStepState.includeDDX;
    this.visitReviewData.ddxOption = this.diagnosisStepState.ddxOption;
    this.visitReviewData.examLocations =
        this.examStepState.examLocationsForSerialization;
    this.visitReviewData.treatmentOptions =
        this.treatmentNoteStepState.selectedTreatmentOptions;
    this.visitReviewData.educationalOptions =
        this.educationalStepState.selectedEducationalOptions.map((option) {
      var link = this
          .diagnosisOptions
          .educationalContent
          .where((e) => e.containsKey(option))
          .toList()
          .first
          .values
          .first;
      return {option: link};
    }).toList();
    this.visitReviewData.followUp = this.followUpStepState.followUpMap;
    this.visitReviewData.patientNote = this.patientNoteStepState.patientNote;
    await firestoreDatabase.saveVisitReview(
        consultId: this.consult.uid, visitReviewData: this.visitReviewData);

    if (this.completedSteps.length == 6) {
      this.consult.state = ConsultStatus.Completed;
      await firestoreDatabase.saveConsult(
          consultId: consult.uid, consult: consult);
      this.visitReviewStatus.updateStatus("All steps completed!");
    }
  }

  void updateContinueBtnPressed(bool pressed) {
    this.continueBtnPressed = pressed;
    notifyListeners(VisitReviewVMProperties.continueBtn);
  }

  void incrementIndex() {
    checkIfWorkSaved();
    updateCompletedStepsList();
    this.currentStep = this.currentStep == VisitReviewSteps.TotalSteps - 1
        ? this.currentStep
        : this.currentStep + 1;
    updateContinueBtnPressed(false);
    this.scrollController.animateTo(
          this.scrollController.offset + 50,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
    notifyListeners(VisitReviewVMProperties.visitReview);
  }

  void decrementIndex() {
    checkIfWorkSaved();
    updateCompletedStepsList();
    this.currentStep = this.currentStep == VisitReviewSteps.DiagnosisStep
        ? this.currentStep
        : this.currentStep - 1;
    this.scrollController.animateTo(
          this.scrollController.offset - 50,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
    notifyListeners(VisitReviewVMProperties.visitReview);
  }

  void updateIndex(int index) {
    checkIfWorkSaved();
    updateCompletedStepsList();
    this.currentStep = index;
    notifyListeners(VisitReviewVMProperties.visitReview);
  }

  /////DIAGNOSIS////

  void setDiagnosisFromPrevData() {
    if (this.visitReviewData.diagnosis.length > 0) {
      this.diagnosisStepState.diagnosis = this.visitReviewData.diagnosis;
      int diagnosisIndex = this
          .consultReviewOptions
          .diagnosisList
          .indexOf(this.diagnosisStepState.diagnosis);
      this.diagnosisStepState.selectedItemIndex =
          diagnosisIndex > -1 ? diagnosisIndex : 0;
      updateDiagnosis(this.diagnosisStepState.selectedItemIndex);
      if (this.diagnosisStepState.minimumRequiredFieldsFilledOut) {
        int index = completedSteps.indexOf(VisitReviewSteps.DiagnosisStep);
        if (index > 0) {
          completedSteps.insert(index, VisitReviewSteps.DiagnosisStep);
        } else {
          completedSteps.add(VisitReviewSteps.DiagnosisStep);
        }
      }
    }
    this.diagnosisStepState.includeDDX = this.visitReviewData.includeDDX;
    if (this.visitReviewData.ddxOption.length > 0) {
      this.diagnosisStepState.ddxOption = this.visitReviewData.ddxOption;
    }
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

  /////END DIAGNOSIS////

  /////EXAM////

  void updateExamStepWith({
    List<String> selectedExamOptions,
    Map<String, String> locationMap,
  }) {
    this.examStepState.selectedExamOptions =
        selectedExamOptions ?? this.examStepState.selectedExamOptions;
    if (locationMap != null) {
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
    }
    notifyListeners(VisitReviewVMProperties.examStep);
  }

  void setExamFromPrevData() {
    if (this.visitReviewData.examLocations.length > 0) {
      this.examStepState.examLocations = this.visitReviewData.examLocations;
      this.examStepState.selectedExamOptions =
          this.visitReviewData.examLocations.map((e) => e.keys.first).toList();
      updateExamStepWith(
          selectedExamOptions: this.examStepState.selectedExamOptions);
      if (this.examStepState.minimumRequiredFieldsFilledOut) {
        int index = completedSteps.indexOf(VisitReviewSteps.ExamStep);
        if (index > 0) {
          completedSteps.insert(index, VisitReviewSteps.ExamStep);
        } else {
          completedSteps.add(VisitReviewSteps.ExamStep);
        }
      }
    }
  }

  /////END EXAM////

  /////TREATMENT////

  void removeTreatmentOption({
    TreatmentOptions selectedTreatment,
  }) {
    this
        .treatmentNoteStepState
        .selectedTreatmentOptions
        .remove(selectedTreatment);
    notifyListeners(VisitReviewVMProperties.treatmentStep);
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

    //this determines if the diagnosis list already has this medication
    int index = this.diagnosisOptions.treatments.indexWhere((element) =>
        element.medicationName == selectedTreatment.medicationName);

    if (index == -1) {
      //this is the "other" option
      this.diagnosisOptions.treatments.last = selectedTreatment;
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

  void setTreatmentFromPrevData() {
    if (this.visitReviewData.treatmentOptions.length > 0) {
      this.treatmentNoteStepState.selectedTreatmentOptions =
          this.visitReviewData.treatmentOptions;

      if (this.treatmentNoteStepState.minimumRequiredFieldsFilledOut) {
        int index = completedSteps.indexOf(VisitReviewSteps.TreatmentStep);
        if (index > 0) {
          completedSteps.insert(index, VisitReviewSteps.TreatmentStep);
        } else {
          completedSteps.add(VisitReviewSteps.TreatmentStep);
        }
      }
    }
  }

  /////END TREATMENT////

  /////FOLLOW UP////

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

  void setFollowUpFromPrevData() {
    if (this.visitReviewData.followUp.length > 0) {
      if (this.visitReviewData.followUp.keys.first != null) {
        this.followUpStepState.followUp =
            this.visitReviewData.followUp.keys.first;
        String followUpValue = this.visitReviewData.followUp.values.first;
        if (followUpValue.length != null) {
          if (this.followUpStepState.followUp == FollowUpSteps.ViaMedicall ||
              this.followUpStepState.followUp == FollowUpSteps.InPerson) {
            this.followUpStepState.duration = followUpValue;
          } else if (this.followUpStepState.followUp ==
              FollowUpSteps.Emergency) {
            this.followUpStepState.documentation = followUpValue;
          }
        }

        if (this.followUpStepState.minimumRequiredFieldsFilledOut) {
          int index = completedSteps.indexOf(VisitReviewSteps.FollowUpStep);
          if (index > 0) {
            completedSteps.insert(index, VisitReviewSteps.FollowUpStep);
          } else {
            completedSteps.add(VisitReviewSteps.FollowUpStep);
          }
        }
      }
    }
  }

  /////END FOLLOW UP////

  /////EDUCATIONAL////

  void updateEducationalInformation({
    List<String> selectedEducationalOptions,
  }) {
    this.educationalStepState.selectedEducationalOptions =
        selectedEducationalOptions ??
            this.educationalStepState.selectedEducationalOptions;
    notifyListeners(VisitReviewVMProperties.educationalContent);
  }

  void setEducationalInfoFromPrevData() {
    if (this.visitReviewData.educationalOptions.length > 0) {
      this.updateEducationalInformation(
        selectedEducationalOptions: this
            .visitReviewData
            .educationalOptions
            .map((e) => e.keys.first)
            .toList(),
      );
      if (this.educationalStepState.minimumRequiredFieldsFilledOut) {
        int index =
            completedSteps.indexOf(VisitReviewSteps.EducationalContentStep);
        if (index > 0) {
          completedSteps.insert(index, VisitReviewSteps.EducationalContentStep);
        } else {
          completedSteps.add(VisitReviewSteps.EducationalContentStep);
        }
      }
    }
  }

  /////END EDUCATIONAL////

  /////PATIENT NOTE////

  void updatePatientNoteStepWith({
    String patientNote,
  }) {
    this.patientNoteStepState.patientNote =
        patientNote ?? this.patientNoteStepState.patientNote;
    notifyListeners(VisitReviewVMProperties.patientNote);
  }

  void setPatientNoteFromPrevData() {
    if (this.visitReviewData.patientNote.length > 0) {
      updatePatientNoteStepWith(patientNote: this.visitReviewData.patientNote);
    }
  }

  /////END PATIENT NOTE////

}

mixin VisitReviewStatus {
  void updateStatus(String msg);
}
