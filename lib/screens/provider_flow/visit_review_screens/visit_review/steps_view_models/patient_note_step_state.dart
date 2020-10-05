import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';

enum PatientNoteSection {
  Introduction,
  UnderstandingDiagnosis,
  Counseling,
  Treatments,
  FurtherTesting,
  Conclusion,
}

class PatientNoteStepState {
  PatientNoteSection currentSection = PatientNoteSection.Introduction;

  PatientTemplateNote patientTemplateNote = PatientTemplateNote();

  //Does intro have a value
  bool get minimumRequiredFieldsFilledOut {
    return this
            .patientTemplateNote
            .introductionTemplate
            .template
            .values
            .first
            .length >
        0;
  }

  String get title {
    if (currentSection == PatientNoteSection.Introduction) {
      return "Introduction";
    } else if (currentSection == PatientNoteSection.UnderstandingDiagnosis) {
      return "Understanding The Diagnosis";
    } else if (currentSection == PatientNoteSection.Counseling) {
      return "Counseling";
    } else if (currentSection == PatientNoteSection.Treatments) {
      return "Treatments";
    } else if (currentSection == PatientNoteSection.FurtherTesting) {
      return "Further Testing";
    } else if (currentSection == PatientNoteSection.Conclusion) {
      return "Conclusion";
    } else {
      return "Error";
    }
  }

  String get body {
    if (currentSection == PatientNoteSection.Introduction) {
      return patientTemplateNote.introductionTemplate.template.values.first;
    } else if (currentSection == PatientNoteSection.UnderstandingDiagnosis) {
      return patientTemplateNote
          .understandingDiagnosisTemplate.template.values.first;
    } else if (currentSection == PatientNoteSection.Counseling) {
      return patientTemplateNote.counselingTemplate.template.values.first;
    } else if (currentSection == PatientNoteSection.Treatments) {
      return patientTemplateNote
          .treatmentRecommendationsTemplate.template.values.first;
    } else if (currentSection == PatientNoteSection.FurtherTesting) {
      return patientTemplateNote.furtherTestingTemplate.template.values.first;
    } else if (currentSection == PatientNoteSection.Conclusion) {
      return patientTemplateNote.conclusionTemplate.template.values.first;
    } else {
      return "Error";
    }
  }
}
