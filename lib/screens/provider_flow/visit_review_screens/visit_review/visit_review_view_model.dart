import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/diagnosis_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/educational_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/exam_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/follow_up_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/treatment_note_step_state.dart';
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
    this.visitReviewData.ddxOptions =
        this.diagnosisStepState.selectedDDXOptions;
    this.visitReviewData.ddxOtherOption =
        this.diagnosisStepState.ddxOtherOption;
    this.visitReviewData.otherDiagnosis =
        this.diagnosisStepState.otherDiagnosis;
    this.visitReviewData.examLocations =
        this.examStepState.examLocationsForSerialization;
    this.visitReviewData.treatmentOptions =
        this.treatmentNoteStepState.selectedTreatmentOptions;
    this.visitReviewData.educationalOptions =
        this.educationalStepState.selectedEducationalOptions.map((option) {
      var link = "";
      if (option == "Other") {
        link = this.educationalStepState.otherEducationalOption;
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

    this.visitReviewData.followUp = this.followUpStepState.followUpMap;

    this.visitReviewData.patientNote =
        this.patientNoteStepState.patientTemplateNote;

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
      if (this.visitReviewData.diagnosis == "Other") {
        if (this.visitReviewData.otherDiagnosis.length == 0) {
          updateDiagnosisStepWith(
              otherDiagnosis:
                  null); //if Other is selected, then an other value from textField has to be entered
        } else {
          updateDiagnosisStepWith(
              otherDiagnosis: this.visitReviewData.diagnosis);
        }
      } else {
        updateDiagnosisStepWith(otherDiagnosis: "");
      }
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
    if (this.visitReviewData.ddxOptions.length > 0) {
      this.diagnosisStepState.selectedDDXOptions =
          this.visitReviewData.ddxOptions;
      this.diagnosisStepState.ddxOtherOption =
          this.visitReviewData.ddxOtherOption;
    }
  }

  Future<void> updateDiagnosis(int selectedItemIndex) async {
    updateDiagnosisStepWith(selectedItemIndex: selectedItemIndex);
    if (this.diagnosisStepState.diagnosis != "Select a Diagnosis") {
      String symptom = consult.providerReclassified
          ? consult.reclassifiedVisit
          : consult.symptom;
      this.diagnosisOptions =
          await firestoreDatabase.consultReviewDiagnosisOptions(
              symptomName: symptom,
              diagnosis: this.diagnosisStepState.diagnosis);
      print("");
    } else {
      this.diagnosisOptions = null;
    }
  }

  void updateDiagnosisStepWith({
    int selectedItemIndex,
    bool includeDDX,
    List<String> selectedDDXOptions,
    String otherDiagnosis,
    String ddxOtherOption,
  }) {
    this.diagnosisStepState.selectedItemIndex =
        selectedItemIndex ?? this.diagnosisStepState.selectedItemIndex;

    this.diagnosisStepState.diagnosis = this
        .consultReviewOptions
        .diagnosisList[this.diagnosisStepState.selectedItemIndex];

    this.diagnosisStepState.includeDDX =
        includeDDX ?? this.diagnosisStepState.includeDDX;

    this.diagnosisStepState.ddxOtherOption =
        ddxOtherOption ?? this.diagnosisStepState.ddxOtherOption;

    if (this.diagnosisStepState.includeDDX &&
        this
            .consultReviewOptions
            .ddxOptions
            .containsKey(this.diagnosisStepState.diagnosis)) {
      this.diagnosisStepState.selectedDDXOptions =
          selectedDDXOptions ?? this.diagnosisStepState.selectedDDXOptions;
    } else {
      this.diagnosisStepState.includeDDX = false;
    }

    if (this.diagnosisStepState.diagnosis == "Other") {
      this.diagnosisStepState.otherDiagnosis =
          otherDiagnosis ?? this.diagnosisStepState.otherDiagnosis;
    } else {
      this.diagnosisStepState.otherDiagnosis = "";
    }

    if (!this.diagnosisStepState.includeDDX ||
        !this.diagnosisStepState.selectedDDXOptions.contains("Other")) {
      this.diagnosisStepState.ddxOtherOption = "";
    }

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
    if (this.visitReviewData.followUp.keys.first.length > 0 &&
        this.visitReviewData.followUp.keys.first != "N/A") {
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
    String otherEducationalOption,
  }) {
    this.educationalStepState.selectedEducationalOptions =
        selectedEducationalOptions ??
            this.educationalStepState.selectedEducationalOptions;
    this.educationalStepState.otherEducationalOption = otherEducationalOption ??
        this.educationalStepState.otherEducationalOption;
    if (this
        .educationalStepState
        .selectedEducationalOptions
        .contains("Other")) {
      this.educationalStepState.otherSelected = true;
    } else {
      this.educationalStepState.otherSelected = false;
      this.educationalStepState.otherEducationalOption = "";
    }

    notifyListeners(VisitReviewVMProperties.educationalContent);
  }

  void setEducationalInfoFromPrevData() {
    if (this.visitReviewData.educationalOptions.length > 0) {
      List<String> educationalOptions = [];
      String otherEduOption = '';
      this.visitReviewData.educationalOptions.forEach((element) {
        String eduOption = element.keys.first;
        educationalOptions.add(eduOption);
        if (eduOption == "Other") {
          otherEduOption = element.values.first;
        }
      });
      this.updateEducationalInformation(
        selectedEducationalOptions: educationalOptions,
        otherEducationalOption: otherEduOption,
      );

      if (this.educationalStepState.minimumRequiredFieldsFilledOut) {
        //insert if it hasn't been inserted already
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

  void updateEditSectionCheckboxesWith(String key, bool isChecked) {
    if (isChecked) {
      this.patientNoteStepState.editedSection[key] =
          "${this.patientNoteStepState.templateSection[key]}";
    } else {
      this.patientNoteStepState.editedSection.remove(key);
    }
    notifyListeners(VisitReviewVMProperties.patientNote);
  }

  void updateEditSectionWith(String key, String value) {
    this.patientNoteStepState.editedSection[key] = value;
    notifyListeners(VisitReviewVMProperties.patientNote);
  }

  void savedSectionUpdate() {
    if (patientNoteStepState.editNoteTitle == "Introduction:") {
      this.updatePatientNoteStepWith(
          introduction: this.patientNoteStepState.editedSection);
    } else if (patientNoteStepState.editNoteTitle ==
        "Understanding the diagnosis:") {
      this.updatePatientNoteStepWith(
          understandingDiagnosis: this.patientNoteStepState.editedSection);
    } else if (patientNoteStepState.editNoteTitle == "Counseling:") {
      this.updatePatientNoteStepWith(
          counseling: this.patientNoteStepState.editedSection);
    } else if (patientNoteStepState.editNoteTitle == "Treatments:") {
      this.updatePatientNoteStepWith(
          treatments: this.patientNoteStepState.editedSection);
    } else if (patientNoteStepState.editNoteTitle ==
        "Further Testing (optional):") {
      this.updatePatientNoteStepWith(
          furtherTesting: this.patientNoteStepState.editedSection);
    } else if (patientNoteStepState.editNoteTitle == "Conclusion:") {
      this.updatePatientNoteStepWith(
          conclusion: this.patientNoteStepState.editedSection);
    }
    print("");
  }

  void updatePatientNoteStepWith({
    Map<String, String> introduction,
    Map<String, String> understandingDiagnosis,
    Map<String, String> counseling,
    Map<String, String> treatments,
    Map<String, String> furtherTesting,
    Map<String, String> other,
    Map<String, String> conclusion,
    bool introductionCheckbox,
    bool understandingCheckbox,
    bool counselingCheckbox,
    bool treatmentsCheckbox,
    bool furtherTestingCheckbox,
    bool conclusionCheckbox,
  }) {
    this.patientNoteStepState.introductionCheckbox =
        introductionCheckbox ?? this.patientNoteStepState.introductionCheckbox;
    this.patientNoteStepState.understandingCheckbox = understandingCheckbox ??
        this.patientNoteStepState.understandingCheckbox;
    this.patientNoteStepState.counselingCheckbox =
        counselingCheckbox ?? this.patientNoteStepState.counselingCheckbox;
    this.patientNoteStepState.treatmentsCheckbox =
        treatmentsCheckbox ?? this.patientNoteStepState.treatmentsCheckbox;
    this.patientNoteStepState.furtherTestingCheckbox = furtherTestingCheckbox ??
        this.patientNoteStepState.furtherTestingCheckbox;
    this.patientNoteStepState.conclusionCheckbox =
        conclusionCheckbox ?? this.patientNoteStepState.conclusionCheckbox;

    if (this.diagnosisOptions != null) {
      if (this.patientNoteStepState.introductionCheckbox) {
        if (patientNoteStepState
                .patientTemplateNote.introductionTemplate.template.length ==
            0) {
          patientNoteStepState
                  .patientTemplateNote.introductionTemplate.template =
              diagnosisOptions
                  .patientNoteTemplate.introductionTemplate.template;
        } else {
          patientNoteStepState
                  .patientTemplateNote.introductionTemplate.template =
              introduction ??
                  patientNoteStepState
                      .patientTemplateNote.introductionTemplate.template;
        }
      } else {
        patientNoteStepState.patientTemplateNote.introductionTemplate.template =
            {};
      }

      if (this.patientNoteStepState.understandingCheckbox) {
        if (patientNoteStepState.patientTemplateNote
                .understandingDiagnosisTemplate.template.length ==
            0) {
          patientNoteStepState
                  .patientTemplateNote.understandingDiagnosisTemplate.template =
              diagnosisOptions
                  .patientNoteTemplate.understandingDiagnosisTemplate.template;
        } else {
          patientNoteStepState
                  .patientTemplateNote.understandingDiagnosisTemplate.template =
              understandingDiagnosis ??
                  patientNoteStepState.patientTemplateNote
                      .understandingDiagnosisTemplate.template;
        }
      } else {
        patientNoteStepState
            .patientTemplateNote.understandingDiagnosisTemplate.template = {};
      }

      if (this.patientNoteStepState.counselingCheckbox) {
        if (patientNoteStepState
                .patientTemplateNote.counselingTemplate.template.length ==
            0) {
          patientNoteStepState.patientTemplateNote.counselingTemplate.template =
              diagnosisOptions.patientNoteTemplate.counselingTemplate.template;
        } else {
          patientNoteStepState.patientTemplateNote.counselingTemplate.template =
              counseling ??
                  patientNoteStepState
                      .patientTemplateNote.counselingTemplate.template;
        }
      } else {
        patientNoteStepState.patientTemplateNote.counselingTemplate.template =
            {};
      }

      if (this.patientNoteStepState.treatmentsCheckbox) {
        if (patientNoteStepState.patientTemplateNote
                .treatmentRecommendationsTemplate.template.length ==
            0) {
          patientNoteStepState.patientTemplateNote
                  .treatmentRecommendationsTemplate.template =
              diagnosisOptions.patientNoteTemplate
                  .treatmentRecommendationsTemplate.template;
        } else {
          patientNoteStepState.patientTemplateNote
                  .treatmentRecommendationsTemplate.template =
              treatments ??
                  patientNoteStepState.patientTemplateNote
                      .treatmentRecommendationsTemplate.template;
        }
      } else {
        patientNoteStepState
            .patientTemplateNote.treatmentRecommendationsTemplate.template = {};
      }

      if (this.patientNoteStepState.furtherTestingCheckbox) {
        if (patientNoteStepState
                .patientTemplateNote.furtherTestingTemplate.template.length ==
            0) {
          patientNoteStepState
                  .patientTemplateNote.furtherTestingTemplate.template =
              diagnosisOptions
                  .patientNoteTemplate.furtherTestingTemplate.template;
        } else {
          patientNoteStepState
                  .patientTemplateNote.furtherTestingTemplate.template =
              furtherTesting ??
                  patientNoteStepState
                      .patientTemplateNote.furtherTestingTemplate.template;
        }
      } else {
        patientNoteStepState
            .patientTemplateNote.furtherTestingTemplate.template = {};
      }

      if (this.patientNoteStepState.conclusionCheckbox) {
        if (patientNoteStepState
                .patientTemplateNote.conclusionTemplate.template.length ==
            0) {
          patientNoteStepState.patientTemplateNote.conclusionTemplate.template =
              diagnosisOptions.patientNoteTemplate.conclusionTemplate.template;
        } else {
          patientNoteStepState.patientTemplateNote.conclusionTemplate.template =
              conclusion ??
                  patientNoteStepState
                      .patientTemplateNote.conclusionTemplate.template;
        }
      } else {
        patientNoteStepState.patientTemplateNote.conclusionTemplate.template =
            {};
      }
    }

    notifyListeners(VisitReviewVMProperties.patientNote);
  }

  void setPatientNoteFromPrevData() {
    if (this.visitReviewData != null) {
      if (this.visitReviewData.patientNote != null) {
        this.patientNoteStepState.patientTemplateNote =
            this.visitReviewData.patientNote;
        if (patientNoteStepState
                .patientTemplateNote.introductionTemplate.template.length >
            0) {
          this.patientNoteStepState.introductionCheckbox = true;
        }
        if (patientNoteStepState.patientTemplateNote
                .understandingDiagnosisTemplate.template.length >
            0) {
          this.patientNoteStepState.understandingCheckbox = true;
        }
        if (patientNoteStepState
                .patientTemplateNote.counselingTemplate.template.length >
            0) {
          this.patientNoteStepState.counselingCheckbox = true;
        }
        if (patientNoteStepState.patientTemplateNote
                .treatmentRecommendationsTemplate.template.length >
            0) {
          this.patientNoteStepState.treatmentsCheckbox = true;
        }
        if (patientNoteStepState
                .patientTemplateNote.furtherTestingTemplate.template.length >
            0) {
          this.patientNoteStepState.furtherTestingCheckbox = true;
        }
        if (patientNoteStepState
                .patientTemplateNote.conclusionTemplate.template.length >
            0) {
          this.patientNoteStepState.conclusionCheckbox = true;
        }
      }
    }
  }

  /////END PATIENT NOTE////

}

mixin VisitReviewStatus {
  void updateStatus(String msg);
}
