class EducationalStepState {
  List<String> selectedEducationalOptions = [];
  bool otherSelected = false;
  String otherEducationalOption = "";

  bool get minimumRequiredFieldsFilledOut {
    if (this.otherSelected) {
      return this.otherEducationalOption.length > 0;
    }
    return this.selectedEducationalOptions.length > 0;
  }
}
