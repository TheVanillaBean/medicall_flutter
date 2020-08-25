class DiagnosisStepState {
  String diagnosis;
  int selectedItemIndex;
  bool includeDDX;
  List<String> selectedDDXOptions = [];
  String ddxOtherOption;

  DiagnosisStepState({
    this.diagnosis = '',
    this.selectedItemIndex = 0,
    this.includeDDX = false,
    this.ddxOtherOption = "",
  });

  bool get minimumRequiredFieldsFilledOut {
    if (this.includeDDX) {
      return this.diagnosis.length > 0 &&
          this.selectedDDXOptions.length > 0 &&
          this.diagnosis != "Select a Diagnosis";
    }
    return this.diagnosis.length > 0 && this.diagnosis != "Select a Diagnosis";
  }
}
