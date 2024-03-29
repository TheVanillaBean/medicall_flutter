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

  PatientTemplateNote patientNote;

  String videoNoteURL;

  VisitReviewData({
    this.diagnosis = "",
    this.otherDiagnosis = "",
    this.includeDDX = false,
    this.ddxOptions = const [],
    this.ddxOtherOption = "",
    this.examLocations = const [],
    this.treatmentOptions = const [],
    this.educationalOptions = const [],
    this.followUp = const {},
    this.videoNoteURL = "",
  });

  factory VisitReviewData.fromMap(
      Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String diagnosis = data['diagnosis'] as String ?? "";
    final String otherDiagnosis = data['other_diagnosis'] as String ?? "";
    final bool includeDDX = data['include_DDX'] as bool ?? false;
    final List<String> ddxOptions =
        (data['ddx_options'] as List).map((e) => e.toString()).toList();
    final String ddxOtherOption = data['ddx_other_option'] as String ?? "";
    List<Map<String, String>> examLocations;
    if (data['exam_locations'] != null && data['exam_locations'] is List) {
      examLocations = (data['exam_locations'] as List)
          .map(
            (e) => (e as Map).map(
              (key, value) => MapEntry(key as String, value as String),
            ),
          )
          .toList();
    }
    List<TreatmentOptions> treatmentOptions;
    if (data['treatment_options'] != null &&
        data['treatment_options'] is List) {
      treatmentOptions = (data['treatment_options'] as List)
          .map(
            (e) => TreatmentOptions.fromMap(e),
          )
          .toList();
    }
    List<Map<String, String>> selectedEducationalOptions;
    if (data['selected_educational_options'] != null &&
        data['selected_educational_options'] is List) {
      selectedEducationalOptions =
          (data['selected_educational_options'] as List)
              .map(
                (e) => (e as Map).map(
                  (key, value) => MapEntry(key as String, value as String),
                ),
              )
              .toList();
    }
    Map<String, String> followUp;
    if (data['follow_up'] != null && data['follow_up'] is Map) {
      followUp = (data['follow_up'] as Map).map(
        (key, value) => MapEntry(key as String, value as String),
      );
    }

    PatientTemplateNote patientNote;
    if (data['patient_note'] != null && data['patient_note'] is Map) {
      patientNote = PatientTemplateNote.fromMap(data['patient_note'] as Map);
    }

    final String videoNoteURL = data['video_note_url'] as String ?? "";

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
      videoNoteURL: videoNoteURL,
    );
    visitReviewData.patientNote = patientNote;
    return visitReviewData;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> e = <String, dynamic>{
      'diagnosis': diagnosis,
      'other_diagnosis': otherDiagnosis,
      'include_DDX': includeDDX,
      'ddx_options': ddxOptions,
      'ddx_other_option': ddxOtherOption,
      'exam_locations': examLocations.toList(),
      'treatment_options': treatmentOptions.map((e) => e.toMap()).toList(),
      'selected_educational_options': educationalOptions.toList(),
    };
    if (followUp != null && followUp.isNotEmpty) {
      e.addAll({
        'follow_up': followUp,
      });
    }
    if (patientNote != null) {
      e.addAll({'patient_note': patientNote.toMap()});
    }
    if (videoNoteURL.length > 0) {
      e.addAll({'video_note_url': videoNoteURL});
    }
    return e;
  }
}
