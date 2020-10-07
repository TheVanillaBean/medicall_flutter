import 'package:Medicall/models/consult-review/patient_note/conclusion_template.dart';
import 'package:Medicall/models/consult-review/patient_note/counseling_template.dart';
import 'package:Medicall/models/consult-review/patient_note/further_testing_template.dart';
import 'package:Medicall/models/consult-review/patient_note/introduction_template.dart';
import 'package:Medicall/models/consult-review/patient_note/treatment_recommendations_template.dart';
import 'package:Medicall/models/consult-review/patient_note/understanding_diagnosis_template.dart';

class PatientTemplateNote {
  IntroductionTemplate introductionTemplate = IntroductionTemplate();
  UnderstandingDiagnosisTemplate understandingDiagnosisTemplate =
      UnderstandingDiagnosisTemplate();
  CounselingTemplate counselingTemplate = CounselingTemplate();
  TreatmentRecommendationsTemplate treatmentRecommendationsTemplate =
      TreatmentRecommendationsTemplate();
  FurtherTestingTemplate furtherTestingTemplate = FurtherTestingTemplate();
  Map<String, String> other = {};
  ConclusionTemplate conclusionTemplate = ConclusionTemplate();

  PatientTemplateNote();

  factory PatientTemplateNote.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    IntroductionTemplate introductionTemplate =
        IntroductionTemplate.fromMap(data['Introduction']);

    UnderstandingDiagnosisTemplate understandingDiagnosisTemplate =
        UnderstandingDiagnosisTemplate.fromMap(
            data['Understanding_The_Diagnosis']);

    CounselingTemplate counselingTemplate =
        CounselingTemplate.fromMap(data['Counseling']);

    TreatmentRecommendationsTemplate treatmentRecommendationsTemplate =
        TreatmentRecommendationsTemplate.fromMap(
            data['Treatment_Recommendations']);

    FurtherTestingTemplate furtherTestingTemplate =
        FurtherTestingTemplate.fromMap(data['Further_Testing']);

    ConclusionTemplate conclusionTemplate =
        ConclusionTemplate.fromMap(data['Conclusion']);

    PatientTemplateNote patientTemplateNote = PatientTemplateNote();
    patientTemplateNote.introductionTemplate = introductionTemplate;
    patientTemplateNote.understandingDiagnosisTemplate =
        understandingDiagnosisTemplate;
    patientTemplateNote.counselingTemplate = counselingTemplate;
    patientTemplateNote.treatmentRecommendationsTemplate =
        treatmentRecommendationsTemplate;
    patientTemplateNote.furtherTestingTemplate = furtherTestingTemplate;
    patientTemplateNote.conclusionTemplate = conclusionTemplate;

    return patientTemplateNote;
  }

  Map<String, dynamic> toMap() {
    dynamic e = <String, dynamic>{
      'Introduction': introductionTemplate.toMap(),
      'Understanding_The_Diagnosis': understandingDiagnosisTemplate.toMap(),
      'Counseling': counselingTemplate.toMap(),
      'Treatment_Recommendations': treatmentRecommendationsTemplate.toMap(),
      'Further_Testing': furtherTestingTemplate.toMap(),
      'Other': other,
      'Conclusion': conclusionTemplate.toMap(),
    };
    return e;
  }
}
