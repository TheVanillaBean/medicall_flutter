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

  bool initFromDiagnosis = true;

  PatientNoteStepState({
    @required this.visitReviewViewModel,
    this.introductionCheckbox = true,
    this.understandingCheckbox = true,
    this.counselingCheckbox = true,
    this.treatmentsCheckbox = false,
    this.furtherTestingCheckbox = true,
    this.conclusionCheckbox = true,
    this.introductionBody = "",
    this.understandingBody = "",
    this.counselingBody = "",
    this.treatmentBody = "",
    this.furtherTestingBody = "",
    this.conclusionBody = "",
  }) {
    this.initFromFirestore();
  }

  void initFromDiagnosisOptions() {
    if (visitReviewViewModel.diagnosisOptions != null &&
        visitReviewViewModel.diagnosisOptions.patientNoteTemplate != null) {
      this.introductionBody = visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.introductionTemplate.body;
      this.understandingBody = visitReviewViewModel.diagnosisOptions
          .patientNoteTemplate.understandingDiagnosisTemplate.body;
      this.counselingBody = visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.counselingTemplate.body;
      this.treatmentBody = "Edit this section to add a treatment note";
      this.furtherTestingBody = visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.furtherTestingTemplate.body;
      this.conclusionBody = visitReviewViewModel
          .diagnosisOptions.patientNoteTemplate.conclusionTemplate.body;
      this.initFromDiagnosis = false;
    }
  }

  void initFromFirestore() {
    if (visitReviewViewModel.visitReviewData.patientNote != null) {
      PatientTemplateNote templateNote =
          visitReviewViewModel.visitReviewData.patientNote;
      if (templateNote.hasIntroduction) {
        this.introductionCheckbox = true;
        this.introductionBody = templateNote.introductionTemplate.body;
      }
      if (templateNote.hasUnderstandingDiagnosis) {
        this.understandingCheckbox = true;
        this.understandingBody =
            templateNote.understandingDiagnosisTemplate.body;
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
  }

  bool get minimumRequiredFieldsFilledOut {
    return (this.introductionCheckbox ||
            this.understandingCheckbox ||
            this.counselingCheckbox ||
            this.treatmentsCheckbox ||
            this.furtherTestingCheckbox ||
            this.conclusionCheckbox) &&
        visitReviewViewModel.diagnosisOptions != null;
  }

  Map<String, String> getEditedSection(PatientNoteSection section) {
    if (visitReviewViewModel.visitReviewData.patientNote != null) {
      PatientTemplateNote templateNote =
          visitReviewViewModel.visitReviewData.patientNote;
      if (section == PatientNoteSection.Introduction) {
        return templateNote.introductionTemplate.template;
      } else if (section == PatientNoteSection.UnderstandingDiagnosis) {
        return templateNote.understandingDiagnosisTemplate.template;
      } else if (section == PatientNoteSection.Counseling) {
        return templateNote.counselingTemplate.template;
      } else if (section == PatientNoteSection.Treatments) {
        return templateNote.treatmentRecommendationsTemplate.template;
      } else if (section == PatientNoteSection.FurtherTesting) {
        return templateNote.furtherTestingTemplate.template;
      } else if (section == PatientNoteSection.Conclusion) {
        return templateNote.conclusionTemplate.template;
      } else {
        return {};
      }
    }
    return {};
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

  Future<void> updateSection(
      PatientNoteSection section, Map<String, String> template) async {
    if (visitReviewViewModel.visitReviewData.patientNote == null) {
      visitReviewViewModel.visitReviewData.patientNote = PatientTemplateNote();
    }
    if (section == PatientNoteSection.Introduction) {
      visitReviewViewModel
          .visitReviewData.patientNote.introductionTemplate.template = template;
    } else if (section == PatientNoteSection.UnderstandingDiagnosis) {
      visitReviewViewModel.visitReviewData.patientNote
          .understandingDiagnosisTemplate.template = template;
    } else if (section == PatientNoteSection.Counseling) {
      visitReviewViewModel
          .visitReviewData.patientNote.counselingTemplate.template = template;
    } else if (section == PatientNoteSection.Treatments) {
      visitReviewViewModel.visitReviewData.patientNote
          .treatmentRecommendationsTemplate.template = template;
    } else if (section == PatientNoteSection.FurtherTesting) {
      visitReviewViewModel.visitReviewData.patientNote.furtherTestingTemplate
          .template = template;
    } else if (section == PatientNoteSection.Conclusion) {
      visitReviewViewModel
          .visitReviewData.patientNote.conclusionTemplate.template = template;
    } else {
      return;
    }
  }

  void checkForCompleted() {
    this.initFromFirestore();
    if (this.minimumRequiredFieldsFilledOut) {
      visitReviewViewModel.addCompletedStep(
        step: VisitReviewSteps.PatientNoteStep,
        setState: true,
      );
    } else {
      visitReviewViewModel.unCompleteStep(
        step: VisitReviewSteps.PatientNoteStep,
        setState: true,
      );
    }
    notifyListeners();
  }

  Future<void> saveSelectedSections() async {
    if (this.introductionCheckbox) {
      await updateSection(PatientNoteSection.Introduction,
          this.getTemplateSection(PatientNoteSection.Introduction));
    } else {
      await updateSection(PatientNoteSection.Introduction, {});
    }
    if (this.understandingCheckbox) {
      await updateSection(PatientNoteSection.UnderstandingDiagnosis,
          this.getTemplateSection(PatientNoteSection.UnderstandingDiagnosis));
    } else {
      await updateSection(PatientNoteSection.UnderstandingDiagnosis, {});
    }
    if (this.counselingCheckbox) {
      await updateSection(PatientNoteSection.Counseling,
          this.getTemplateSection(PatientNoteSection.Counseling));
    } else {
      await updateSection(PatientNoteSection.Counseling, {});
    }
    if (this.treatmentsCheckbox) {
      await updateSection(PatientNoteSection.Treatments,
          this.getEditedSection(PatientNoteSection.Treatments));
    } else {
      await updateSection(PatientNoteSection.Treatments, {});
    }
    if (this.furtherTestingCheckbox) {
      await updateSection(PatientNoteSection.FurtherTesting,
          this.getTemplateSection(PatientNoteSection.FurtherTesting));
    } else {
      await updateSection(PatientNoteSection.FurtherTesting, {});
    }
    if (this.conclusionCheckbox) {
      await updateSection(PatientNoteSection.Conclusion,
          this.getTemplateSection(PatientNoteSection.Conclusion));
    } else {
      await updateSection(PatientNoteSection.Conclusion, {});
    }
    await this.visitReviewViewModel.savePatientNoteToFirestore(this);
    checkForCompleted();
  }

  Future<void> updateWith({
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
  }) async {
    this.introductionCheckbox =
        introductionCheckbox ?? this.introductionCheckbox;
    this.understandingCheckbox =
        understandingCheckbox ?? this.understandingCheckbox;
    this.counselingCheckbox = counselingCheckbox ?? this.counselingCheckbox;
    this.treatmentsCheckbox = treatmentsCheckbox ?? this.treatmentsCheckbox;
    this.furtherTestingCheckbox =
        furtherTestingCheckbox ?? this.furtherTestingCheckbox;
    this.conclusionCheckbox = conclusionCheckbox ?? this.conclusionCheckbox;
    notifyListeners();
  }
}
