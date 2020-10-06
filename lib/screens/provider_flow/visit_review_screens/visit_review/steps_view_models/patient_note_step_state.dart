import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';

enum PatientNoteSection {
  Introduction,
  UnderstandingDiagnosis,
  Counseling,
  Treatments,
  FurtherTesting,
  Other,
  Conclusion,
}

class PatientNoteStepState {
  bool introductionCheckbox = false;
  bool understandingCheckbox = false;
  bool counselingCheckbox = false;
  bool treatmentsCheckbox = false;
  bool furtherTestingCheckbox = false;
  bool conclusionCheckbox = false;

  PatientNoteSection currentSection = PatientNoteSection.Introduction;

  PatientTemplateNote patientTemplateNote = PatientTemplateNote();

  String editNoteTitle = "";
  String editNoteBody = "";

  void setEditSectionNoteBody(String title, DiagnosisOptions diagnosisOptions) {
    editNoteTitle = title;
    editNoteBody = sectionBody(editNoteTitle, diagnosisOptions);
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
