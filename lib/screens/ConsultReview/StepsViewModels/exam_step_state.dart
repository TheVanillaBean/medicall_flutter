class ExamStepState {
  List<String> selectedExamOptions = [];
  List<Map<String, String>> examLocations = [];

  bool get minimumRequiredFieldsFilledOut {
    return this.selectedExamOptions.length > 0;
  }

  List<Map<String, String>> get examLocationsForSerialization {
    if (examLocations.length == 0) {
      return selectedExamOptions.map((e) => {e: "N/A"}).toList();
    } else {
      return examLocations;
    }
  }
}
