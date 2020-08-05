import 'package:Medicall/models/consult-review/treatment_options.dart';

//Will be used to store the actual provider answers
class VisitReviewData {
  String diagnosis;
  bool includeDDX;
  String ddxOption;

  List<Map<String, String>> examLocations;

  List<TreatmentOptions> treatmentOptions;

  List<Map<String, String>> educationalOptions;

  Map<String, String> followUp;

  String patientNote;

  VisitReviewData({
    this.diagnosis = "",
    this.includeDDX = false,
    this.ddxOption = "",
    this.examLocations = const [],
    this.treatmentOptions = const [],
    this.educationalOptions = const [],
    this.followUp = const {"": ""},
    this.patientNote = "",
  });

  factory VisitReviewData.fromMap(
      Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String diagnosis = data['diagnosis'] as String;
    final bool includeDDX = data['include_DDX'] as bool;
    final String ddxOption = data['ddx_option'] as String;
    final List<Map<String, String>> examLocations =
        (data['exam_locations'] as List)
            .map(
              (e) => (e as Map).map(
                (key, value) => MapEntry(key as String, value as String),
              ),
            )
            .toList();
    final List<TreatmentOptions> treatmentOptions =
        (data['treatment_options'] as List)
            .map(
              (e) => TreatmentOptions.fromMap(e),
            )
            .toList();
    final List<Map<String, String>> selectedEducationalOptions =
        (data['selected_educational_options'] as List)
            .map(
              (e) => (e as Map).map(
                (key, value) => MapEntry(key as String, value as String),
              ),
            )
            .toList();
    final Map<String, String> followUp = (data['follow_up'] as Map).map(
      (key, value) => MapEntry(key as String, value as String),
    );
    final String patientNote = data['patient_note'] as String;

    return VisitReviewData(
      diagnosis: diagnosis,
      includeDDX: includeDDX,
      ddxOption: ddxOption,
      examLocations: examLocations,
      treatmentOptions: treatmentOptions,
      educationalOptions: selectedEducationalOptions,
      followUp: followUp,
      patientNote: patientNote,
    );
  }

  Map<String, dynamic> toMap() {
    dynamic e = <String, dynamic>{
      'diagnosis': diagnosis,
      'include_DDX': includeDDX,
      'ddx_option': ddxOption,
      'exam_locations': examLocations.toList(),
      'treatment_options': treatmentOptions.map((e) => e.toMap()).toList(),
      'selected_educational_options': educationalOptions,
      'follow_up': followUp,
      'patient_note': patientNote,
    };
    return e;
  }
}
