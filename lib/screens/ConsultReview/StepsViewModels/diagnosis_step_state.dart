class DiagnosisStepState {
  String diagnosis;
  int selectedItemIndex;
  bool includeDDX;
  String ddxOption;

  DiagnosisStepState({
    this.diagnosis = '',
    this.selectedItemIndex = 0,
    this.includeDDX = false,
    this.ddxOption = '',
  });

  bool get minimumRequiredFieldsFilledOut {
    return this.diagnosis.length > 0;
  }
}
