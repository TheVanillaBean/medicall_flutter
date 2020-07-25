class DiagnosisStepState {
  String diagnosis;
  int selectedItemIndex;
  bool includeDDX;
  String ddxOption;

  DiagnosisStepState({
    this.diagnosis = '',
    this.selectedItemIndex = 2,
    this.includeDDX = false,
    this.ddxOption = '',
  });
}
