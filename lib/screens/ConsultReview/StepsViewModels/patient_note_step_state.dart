import 'package:Medicall/models/consult-review/patient_note_template_model.dart';

class PatientNoteStepState {
  String patientNote = '';

  String getPatientNoteTemplate(String patientName, String providerName,
      PatientTemplateNote patientTemplateNote) {
    String note = "Dear $patientName,";
    note += "\n";
    note += "\n";
    note += patientTemplateNote.intro;
    note += "\n";
    note += patientTemplateNote.body["FINASTERIDE"];
    note += "\n";
    note += patientTemplateNote.conclusion;
    note += "\n";
    note += "\n";
    note += "Regards,";
    note += "\n";
    note += providerName;
    return note;
  }

  bool get minimumRequiredFieldsFilledOut {
    return this.patientNote.length > 0;
  }
}
