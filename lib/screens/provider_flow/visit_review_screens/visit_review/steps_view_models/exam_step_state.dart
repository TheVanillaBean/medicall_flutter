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

  String getExamLocation(String exam) {
    List<Map<String, String>> locations =
        examLocations.where((element) => element.keys.first == exam).toList();
    if (locations.length > 0) {
      return locations.first.values.first;
    }
    return "";
  }
}
