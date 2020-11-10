import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';

//Will be used to store the actual provider answers
class VisitReviewData {
  String diagnosis;
  String otherDiagnosis;
  bool includeDDX;
  List<String> ddxOptions;
  String ddxOtherOption;

  List<Map<String, String>> examLocations;

  List<TreatmentOptions> treatmentOptions;

  List<Map<String, String>> educationalOptions;

  Map<String, String> followUp;

  PatientTemplateNote patientNote = PatientTemplateNote();

  VisitReviewData({
    this.diagnosis = "",
    this.otherDiagnosis = "",
    this.includeDDX = false,
    this.ddxOptions = const [],
    this.ddxOtherOption = "",
    this.examLocations = const [],
    this.treatmentOptions = const [],
    this.educationalOptions = const [],
    this.followUp = const {"": ""},
  });

  factory VisitReviewData.fromMap(
      Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String diagnosis = data['diagnosis'] as String;
    final String otherDiagnosis = data['other_diagnosis'] as String;
    final bool includeDDX = data['include_DDX'] as bool;
    final List<String> ddxOptions =
        (data['ddx_options'] as List).map((e) => e.toString()).toList();
    final String ddxOtherOption = data['ddx_other_option'] as String ?? "";
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

    PatientTemplateNote patientNote = PatientTemplateNote();
    if (data['patient_note'] != null && data['patient_note'] is Map) {
      patientNote = PatientTemplateNote.fromMap(data['patient_note'] as Map);
    }

    final VisitReviewData visitReviewData = VisitReviewData(
      diagnosis: diagnosis,
      otherDiagnosis: otherDiagnosis,
      includeDDX: includeDDX,
      ddxOptions: ddxOptions,
      ddxOtherOption: ddxOtherOption,
      examLocations: examLocations,
      treatmentOptions: treatmentOptions,
      educationalOptions: selectedEducationalOptions,
      followUp: followUp,
    );
    visitReviewData.patientNote = patientNote;
    return visitReviewData;
  }

  Map<String, dynamic> toMap() {
    dynamic e = <String, dynamic>{
      'diagnosis': diagnosis,
      'other_diagnosis': otherDiagnosis,
      'include_DDX': includeDDX,
      'ddx_options': ddxOptions,
      'ddx_other_option': ddxOtherOption,
      'exam_locations': examLocations.toList(),
      'treatment_options': treatmentOptions.map((e) => e.toMap()).toList(),
      'selected_educational_options': educationalOptions,
      'follow_up': followUp,
      'patient_note': patientNote.toMap(),
    };
    return e;
  }
}
