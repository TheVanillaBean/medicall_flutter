class ExamStepState {
  List<String> selectedExamOptions = [];
  List<Map<String, String>> examLocations = [];

  bool get minimumRequiredFieldsFilledOut {
    return this.selectedExamOptions.length > 0;
  }
}
