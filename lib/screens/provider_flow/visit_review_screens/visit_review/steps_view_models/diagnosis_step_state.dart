import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/cupertino.dart';

class DiagnosisStepState with ChangeNotifier {
  static const String UnselectedDiagnosis = "Select a Diagnosis";

  VisitReviewViewModel visitReviewViewModel;
  String diagnosis;
  int selectedItemIndex;
  bool includeDDX;
  List<String> selectedDDXOptions = [];
  String otherDiagnosis;
  String ddxOtherOption;

  DiagnosisStepState({
    @required this.visitReviewViewModel,
    this.diagnosis = UnselectedDiagnosis,
    this.selectedItemIndex = 0,
    this.includeDDX = false,
    this.ddxOtherOption = "",
    this.otherDiagnosis = "",
  });

  bool get canContinue {
    return minimumRequiredFieldsFilledOut;
  }

  bool get minimumRequiredFieldsFilledOut {
    if (this.includeDDX) {
      return this.diagnosis != UnselectedDiagnosis &&
          this.selectedDDXOptions.length > 0;
    }
    if (this.diagnosis == "Other") {
      return this.diagnosis != UnselectedDiagnosis &&
          this.otherDiagnosis.length > 0;
    }
    return this.diagnosis != UnselectedDiagnosis;
  }

  // Gets the review options for all other steps based on original symptom on reclassified symptom, if it was reclassified
  Future<void> updateReviewOptionsForDiagnosis(int selectedItemIndex) async {
    this.selectedItemIndex = selectedItemIndex ?? this.selectedItemIndex;
    if (this.selectedItemIndex != null && this.selectedItemIndex > 0) {
      this.diagnosis = visitReviewViewModel
          .consultReviewOptions.diagnosisList[this.selectedItemIndex];

      String symptom = visitReviewViewModel.consult.providerReclassified
          ? visitReviewViewModel.consult.reclassifiedVisit
          : visitReviewViewModel.consult.symptom;
      visitReviewViewModel.diagnosisOptions = await visitReviewViewModel
          .firestoreDatabase
          .consultReviewDiagnosisOptions(
              symptomName: symptom, diagnosis: this.diagnosis);

      updateDiagnosisStepWith();
    } else {
      this.diagnosis = UnselectedDiagnosis;
      updateDiagnosisStepWith();
    }
  }

  void updateDiagnosisStepWith({
    int selectedItemIndex,
    bool includeDDX,
    List<String> selectedDDXOptions,
    String otherDiagnosis,
    String ddxOtherOption,
  }) {
    this.otherDiagnosis = this.diagnosis == "Other"
        ? (otherDiagnosis ?? this.otherDiagnosis)
        : "";

    this.includeDDX = includeDDX ?? this.includeDDX;

    this.selectedDDXOptions =
        this.includeDDX ? (selectedDDXOptions ?? this.selectedDDXOptions) : [];

    this.ddxOtherOption = ddxOtherOption ?? this.ddxOtherOption;

    bool includeDDXOtherOption =
        this.includeDDX && this.selectedDDXOptions.contains("Other");

    if (!includeDDXOtherOption) {
      this.ddxOtherOption = "";
    }

    if (this.diagnosis == UnselectedDiagnosis && this.includeDDX) {
      this.includeDDX = false;
      throw "Please select a diagnosis first by tapping the dropdown";
    }

    notifyListeners();
  }
}
