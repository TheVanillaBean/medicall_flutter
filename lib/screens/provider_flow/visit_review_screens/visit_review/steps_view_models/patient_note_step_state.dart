import 'package:Medicall/models/consult-review/patient_note/patient_note_template_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/foundation.dart';

enum PatientNoteSection {
  Introduction,
  UnderstandingDiagnosis,
  Counseling,
  Treatments,
  FurtherTesting,
  Other,
  Conclusion,
}

class PatientNoteStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;

  bool introductionCheckbox;
  bool understandingCheckbox;
  bool counselingCheckbox;
  bool treatmentsCheckbox;
  bool furtherTestingCheckbox;
  bool conclusionCheckbox;

  String introductionBody;
  String understandingBody;
  String counselingBody;
  String treatmentBody;
  String furtherTestingBody;
  String conclusionBody;

  bool editedStep = false;

  PatientNoteStepState({
    @required this.visitReviewViewModel,
    this.introductionCheckbox = true,
    this.understandingCheckbox = false,
    this.counselingCheckbox = false,
    this.treatmentsCheckbox = false,
    this.furtherTestingCheckbox = false,
    this.conclusionCheckbox = false,
    this.introductionBody = "",
    this.understandingBody = "",
    this.counselingBody = "",
    this.treatmentBody = "",
    this.furtherTestingBody = "",
    this.conclusionBody = "",
  }) {
    this.initFromDiagnosisOptions();
    this.initFromFirestore();
  }

  void initFromDiagnosisOptions() {
    this.introductionBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.introductionTemplate.body;
    this.understandingBody = visitReviewViewModel.diagnosisOptions
        .patientNoteTemplate.understandingDiagnosisTemplate.body;
    this.counselingBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.counselingTemplate.body;
    this.treatmentBody = visitReviewViewModel.diagnosisOptions
        .patientNoteTemplate.treatmentRecommendationsTemplate.body;
    this.furtherTestingBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.furtherTestingTemplate.body;
    this.conclusionBody = visitReviewViewModel
        .diagnosisOptions.patientNoteTemplate.conclusionTemplate.body;
  }

  void initFromFirestore() {
    PatientTemplateNote templateNote =
        visitReviewViewModel.visitReviewData.patientNote;
    if (templateNote.hasIntroduction) {
      this.introductionCheckbox = true;
      this.introductionBody = templateNote.introductionTemplate.body;
    }
    if (templateNote.hasUnderstandingDiagnosis) {
      this.understandingCheckbox = true;
      this.understandingBody = templateNote.understandingDiagnosisTemplate.body;
    }
    if (templateNote.hasTreatmentRecommendations) {
      this.treatmentsCheckbox = true;
      this.treatmentBody = templateNote.treatmentRecommendationsTemplate.body;
    }
    if (templateNote.hasFurtherTesting) {
      this.furtherTestingCheckbox = true;
      this.furtherTestingBody = templateNote.furtherTestingTemplate.body;
    }
    if (templateNote.hasCounseling) {
      this.counselingCheckbox = true;
      this.counselingBody = templateNote.counselingTemplate.body;
    }
    if (templateNote.hasConclusion) {
      this.conclusionCheckbox = true;
      this.conclusionBody = templateNote.conclusionTemplate.body;
    }
    if (this.minimumRequiredFieldsFilledOut) {
      visitReviewViewModel.addCompletedStep(
        step: VisitReviewSteps.PatientNoteStep,
        setState: false,
      );
    }
  }

  bool get minimumRequiredFieldsFilledOut {
    return this.introductionCheckbox;
  }

  Map<String, String> getEditedSection(PatientNoteSection section) {
    PatientTemplateNote templateNote =
        visitReviewViewModel.visitReviewData.patientNote;
    if (section == PatientNoteSection.Introduction) {
      return templateNote.introductionTemplate.template;
    } else if (section == PatientNoteSection.UnderstandingDiagnosis) {
      return templateNote.understandingDiagnosisTemplate.template;
    } else if (section == PatientNoteSection.Counseling) {
      return templateNote.counselingTemplate.template;
    } else if (section == PatientNoteSection.Treatments) {
      return templateNote.furtherTestingTemplate.template;
    } else if (section == PatientNoteSection.FurtherTesting) {
      return templateNote.furtherTestingTemplate.template;
    } else if (section == PatientNoteSection.Conclusion) {
      return templateNote.conclusionTemplate.template;
    } else {
      return {};
    }
  }

  Map<String, String> getTemplateSection(PatientNoteSection section) {
    if (section == PatientNoteSection.Introduction) {
      return visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.introductionTemplate.template;
    } else if (section == PatientNoteSection.UnderstandingDiagnosis) {
      return visitReviewViewModel.diagnosisOptions.patientNoteTemplate
          .understandingDiagnosisTemplate.template;
    } else if (section == PatientNoteSection.Counseling) {
      return visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.counselingTemplate.template;
    } else if (section == PatientNoteSection.Treatments) {
      return visitReviewViewModel.diagnosisOptions.patientNoteTemplate
          .treatmentRecommendationsTemplate.template;
    } else if (section == PatientNoteSection.FurtherTesting) {
      return visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.furtherTestingTemplate.template;
    } else if (section == PatientNoteSection.Conclusion) {
      return visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.conclusionTemplate.template;
    } else {
      return {};
    }
  }

  void updateWith({
    bool introductionCheckbox,
    bool understandingCheckbox,
    bool counselingCheckbox,
    bool treatmentsCheckbox,
    bool furtherTestingCheckbox,
    bool conclusionCheckbox,
    String introductionBody,
    String understandingBody,
    String counselingBody,
    String treatmentBody,
    String furtherTestingBody,
    String conclusionBody,
  }) {
    this.editedStep = true;

    this.introductionCheckbox =
        introductionCheckbox ?? this.introductionCheckbox;
    this.understandingCheckbox =
        understandingCheckbox ?? this.understandingCheckbox;
    this.counselingCheckbox = counselingCheckbox ?? this.counselingCheckbox;
    this.treatmentsCheckbox = treatmentsCheckbox ?? this.treatmentsCheckbox;
    this.furtherTestingCheckbox =
        furtherTestingCheckbox ?? this.furtherTestingCheckbox;
    this.conclusionCheckbox = conclusionCheckbox ?? this.conclusionCheckbox;

    this.introductionBody = introductionBody ?? this.introductionBody;
    this.understandingBody = understandingBody ?? this.understandingBody;
    this.counselingBody = counselingBody ?? this.counselingBody;
    this.treatmentBody = treatmentBody ?? this.treatmentBody;
    this.furtherTestingBody = furtherTestingBody ?? this.furtherTestingBody;
    this.conclusionBody = conclusionBody ?? this.conclusionBody;

    notifyListeners();
  }
}
