class DiagnosisStepState {
  String diagnosis;
  int selectedItemIndex;
  bool includeDDX;
  List<String> selectedDDXOptions = [];
  String otherDiagnosis;
  String ddxOtherOption;

  DiagnosisStepState({
    this.diagnosis = '',
    this.selectedItemIndex = 0,
    this.includeDDX = false,
    this.ddxOtherOption = "",
    this.otherDiagnosis = "",
  });

  bool get minimumRequiredFieldsFilledOut {
    if (this.includeDDX) {
      return this.diagnosis.length > 0 &&
          this.selectedDDXOptions.length > 0 &&
          this.diagnosis != "Select a Diagnosis";
    }
    if (this.diagnosis == "Other") {
      return this.diagnosis.length > 0 &&
          this.otherDiagnosis.length > 0 &&
          this.diagnosis != "Select a Diagnosis";
    }
    return this.diagnosis.length > 0 && this.diagnosis != "Select a Diagnosis";
  }
}
