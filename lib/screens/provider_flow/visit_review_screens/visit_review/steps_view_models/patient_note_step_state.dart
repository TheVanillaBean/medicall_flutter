import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';

class PatientNoteStepState {
  String patientNote = '';

  Map<String, String> introduction = {};
  Map<String, String> understandingDiagnosis = {};
  Map<String, String> counseling = {};
  Map<String, String> treatments = {};
  Map<String, String> furtherTesting = {};
  Map<String, String> closing = {};

  String getPatientNoteTemplate(String patientName, String providerName,
      PatientTemplateNote patientTemplateNote) {
    if (patientNote.length > 0) {
      return patientNote;
    } else {
      String note = "Dear $patientName,";
      note += "\n";
      note += "\n";
      note += patientTemplateNote.introductionTemplate.toString();
      note += "\n";
      note += patientTemplateNote.introductionTemplate.toString();
      note += "\n";
      note += patientTemplateNote.introductionTemplate.toString();
      note += "\n";
      note += "\n";
      note += "Regards,";
      note += "\n";
      note += providerName;
      patientNote = note;
      return note;
    }
  }

  bool get minimumRequiredFieldsFilledOut {
    return this.patientNote.length > 0;
  }
}
