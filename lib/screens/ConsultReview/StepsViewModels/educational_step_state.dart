class EducationalStepState {
  List<String> selectedEducationalOptions = [];

  bool get minimumRequiredFieldsFilledOut {
    return this.selectedEducationalOptions.length > 0;
  }
}
