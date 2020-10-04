import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:flutter/foundation.dart';

class DiagnosisOptions {
  String diagnosis;
  List<String> exam;
  List<Map<String, String>> educationalContent;
  List<TreatmentOptions> treatments;
  PatientTemplateNote patientNoteTemplate;

  DiagnosisOptions({
    @required this.diagnosis,
    @required this.exam,
    @required this.educationalContent,
    @required this.treatments,
    @required this.patientNoteTemplate,
  });

  factory DiagnosisOptions.fromMap(
      Map<String, dynamic> data, String diagnosis) {
    if (data == null) {
      return null;
    }

    final List<Map<String, dynamic>> educationalContent =
        (data['educational'] as List)
            .map(
              (item) => (item as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  value as String,
                ),
              ),
            )
            .toList();

    final List<String> exam =
        (data['exam'] as List).map((e) => e.toString()).toList();

    final List<TreatmentOptions> treatments = (data['treatment'] as List)
        .map(
          (treatmentOptions) => TreatmentOptions.fromMap(treatmentOptions),
        )
        .toList();

    final PatientTemplateNote patientNote =
        PatientTemplateNote.fromMap(data['patientNote']);

    return DiagnosisOptions(
      diagnosis: diagnosis,
      exam: exam,
      educationalContent: educationalContent,
      treatments: treatments,
      patientNoteTemplate: patientNote,
    );
  }
}
