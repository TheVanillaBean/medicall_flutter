import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/foundation.dart';

enum PatientNoteSection {
  Introduction,
  UnderstandingDiagnosis,
  Counseling,
  Treatments,
  FurtherTesting,
  Other,
  Conclusion,
}

class PatientNoteStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;

  bool introductionCheckbox;
  bool understandingCheckbox;
  bool counselingCheckbox;
  bool treatmentsCheckbox;
  bool furtherTestingCheckbox;
  bool conclusionCheckbox;

  String introductionBody;
  String understandingBody;
  String counselingBody;
  String treatmentBody;
  String furtherTestingBody;
  String conclusionBody;

  PatientTemplateNote patientTemplateNote = PatientTemplateNote();

  String editNoteTitle = "";
  Map<String, dynamic> templateSection = {};
  Map<String, dynamic> editedSection = {};

  PatientNoteStepState({
    @required this.visitReviewViewModel,
    this.introductionCheckbox = true,
    this.understandingCheckbox = false,
    this.counselingCheckbox = false,
    this.treatmentsCheckbox = false,
    this.furtherTestingCheckbox = false,
    this.conclusionCheckbox = false,
    this.introductionBody = "",
    this.understandingBody = "",
    this.counselingBody = "",
    this.treatmentBody = "",
    this.furtherTestingBody = "",
    this.conclusionBody = "",
  }) {
    this.initFromDiagnosisOptions();
    this.initFromFirestore();
  }

  void initFromDiagnosisOptions() {
    this.introductionBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.introductionTemplate.body;
    this.understandingBody = visitReviewViewModel.diagnosisOptions
        .patientNoteTemplate.understandingDiagnosisTemplate.body;
    this.counselingBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.counselingTemplate.body;
    this.treatmentBody = visitReviewViewModel.diagnosisOptions
        .patientNoteTemplate.treatmentRecommendationsTemplate.body;
    this.furtherTestingBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.furtherTestingTemplate.body;
    this.conclusionBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.conclusionTemplate.body;
  }

  void initFromFirestore() {
    PatientTemplateNote templateNote =
        visitReviewViewModel.visitReviewData.patientNote;
    if (templateNote.hasIntroduction) {
      this.introductionCheckbox = true;
      this.introductionBody = templateNote.introductionTemplate.body;
    }
    if (templateNote.hasUnderstandingDiagnosis) {
      this.understandingCheckbox = true;
      this.understandingBody = templateNote.understandingDiagnosisTemplate.body;
    }
    if (templateNote.hasTreatmentRecommendations) {
      this.treatmentsCheckbox = true;
      this.treatmentBody = templateNote.treatmentRecommendationsTemplate.body;
    }
    if (templateNote.hasFurtherTesting) {
      this.furtherTestingCheckbox = true;
      this.furtherTestingBody = templateNote.furtherTestingTemplate.body;
    }
    if (templateNote.hasCounseling) {
      this.counselingCheckbox = true;
      this.counselingBody = templateNote.counselingTemplate.body;
    }
    if (templateNote.hasConclusion) {
      this.conclusionCheckbox = true;
      this.conclusionBody = templateNote.conclusionTemplate.body;
    }
  }

  void setEditSectionNoteBody(
    String section,
    DiagnosisOptions diagnosisOptions,
  ) {
    editNoteTitle = section;
    if (section == "Introduction: (Required)") {
      templateSection =
          diagnosisOptions.patientNoteTemplate.introductionTemplate.template;
      editedSection = patientTemplateNote.introductionTemplate.template;
    } else if (section == "Understanding the diagnosis:") {
      templateSection = diagnosisOptions
          .patientNoteTemplate.understandingDiagnosisTemplate.template;
      editedSection =
          patientTemplateNote.understandingDiagnosisTemplate.template;
    } else if (section == "Counseling:") {
      templateSection =
          diagnosisOptions.patientNoteTemplate.counselingTemplate.template;
      editedSection = patientTemplateNote.counselingTemplate.template;
    } else if (section == "Treatments:") {
      templateSection = diagnosisOptions
          .patientNoteTemplate.treatmentRecommendationsTemplate.template;
      editedSection = {
        patientTemplateNote
                .treatmentRecommendationsTemplate.template.keys.first:
            patientTemplateNote
                .treatmentRecommendationsTemplate.template.values.first
      } as Map<String, String>;
    } else if (section == "Further Testing (optional):") {
      templateSection =
          diagnosisOptions.patientNoteTemplate.furtherTestingTemplate.template;
      editedSection = patientTemplateNote.furtherTestingTemplate.template;
    } else if (section == "Conclusion:") {
      templateSection =
          diagnosisOptions.patientNoteTemplate.conclusionTemplate.template;
      editedSection = patientTemplateNote.conclusionTemplate.template;
    }
  }

  //Does intro have a value
  bool get minimumRequiredFieldsFilledOut {
    return patientTemplateNote.introductionTemplate.template.length > 0;
  }

  //return body from diagnosis from patient note or patient step state patient note
  String sectionBody(String section, DiagnosisOptions diagnosisOptions) {
    if (section == "Introduction:") {
      if (this.patientTemplateNote.introductionTemplate.template.length == 0) {
        return diagnosisOptions
            .patientNoteTemplate.introductionTemplate.template.values.first;
      } else {
        return this
            .patientTemplateNote
            .introductionTemplate
            .template
            .values
            .first;
      }
    } else if (section == "Understanding the diagnosis:") {
      if (this
              .patientTemplateNote
              .understandingDiagnosisTemplate
              .template
              .length ==
          0) {
        return diagnosisOptions.patientNoteTemplate
            .understandingDiagnosisTemplate.template.values.first;
      } else {
        return this
            .patientTemplateNote
            .understandingDiagnosisTemplate
            .template
            .values
            .first;
      }
    } else if (section == "Counseling:") {
      if (this.patientTemplateNote.counselingTemplate.template.length == 0) {
        return diagnosisOptions
            .patientNoteTemplate.counselingTemplate.template.values.first;
      } else {
        return this
            .patientTemplateNote
            .counselingTemplate
            .template
            .values
            .first;
      }
    } else if (section == "Treatments:") {
      if (this
              .patientTemplateNote
              .treatmentRecommendationsTemplate
              .template
              .length ==
          0) {
        return diagnosisOptions.patientNoteTemplate
            .treatmentRecommendationsTemplate.template.values.first;
      } else {
        return this
            .patientTemplateNote
            .treatmentRecommendationsTemplate
            .template
            .values
            .first;
      }
    } else if (section == "Further Testing (optional):") {
      if (this.patientTemplateNote.furtherTestingTemplate.template.length ==
          0) {
        return diagnosisOptions
            .patientNoteTemplate.furtherTestingTemplate.template.values.first;
      } else {
        return this
            .patientTemplateNote
            .furtherTestingTemplate
            .template
            .values
            .first;
      }
    } else if (section == "Conclusion:") {
      if (this.patientTemplateNote.conclusionTemplate.template.length == 0) {
        return diagnosisOptions
            .patientNoteTemplate.conclusionTemplate.template.values.first;
      } else {
        return this
            .patientTemplateNote
            .conclusionTemplate
            .template
            .values
            .first;
      }
    }
    return "";
  }
}
