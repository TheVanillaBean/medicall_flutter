class DiagnosisStepState {
  String diagnosis;
  int selectedItemIndex;
  bool includeDDX;
  List<String> selectedDDXOptions = [];

  DiagnosisStepState({
    this.diagnosis = '',
    this.selectedItemIndex = 0,
    this.includeDDX = false,
  });

  bool get minimumRequiredFieldsFilledOut {
    if (this.includeDDX) {
      return this.diagnosis.length > 0 && this.selectedDDXOptions.length > 0;
    }
    return this.diagnosis.length > 0;
  }
}
