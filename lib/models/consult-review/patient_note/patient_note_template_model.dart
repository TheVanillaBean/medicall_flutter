import 'package:Medicall/models/consult-review/patient_note/conclusion_template.dart';
import 'package:Medicall/models/consult-review/patient_note/counseling_template.dart';
import 'package:Medicall/models/consult-review/patient_note/further_testing_template.dart';
import 'package:Medicall/models/consult-review/patient_note/introduction_template.dart';
import 'package:Medicall/models/consult-review/patient_note/treatment_recommendations_template.dart';
import 'package:Medicall/models/consult-review/patient_note/understanding_diagnosis_template.dart';
import 'package:flutter/foundation.dart';

class PatientTemplateNote {
  IntroductionTemplate introductionTemplate;
  UnderstandingDiagnosisTemplate understandingDiagnosisTemplate;
  CounselingTemplate counselingTemplate;
  TreatmentRecommendationsTemplate treatmentRecommendationsTemplate;
  FurtherTestingTemplate furtherTestingTemplate;
  ConclusionTemplate conclusionTemplate;

  PatientTemplateNote({
    @required this.introductionTemplate,
    @required this.understandingDiagnosisTemplate,
    @required this.counselingTemplate,
    @required this.treatmentRecommendationsTemplate,
    @required this.furtherTestingTemplate,
    @required this.conclusionTemplate,
  });

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

    return PatientTemplateNote(
      introductionTemplate: introductionTemplate,
      understandingDiagnosisTemplate: understandingDiagnosisTemplate,
      counselingTemplate: counselingTemplate,
      treatmentRecommendationsTemplate: treatmentRecommendationsTemplate,
      furtherTestingTemplate: furtherTestingTemplate,
      conclusionTemplate: conclusionTemplate,
    );
  }
}
