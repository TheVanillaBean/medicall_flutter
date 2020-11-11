import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:flutter/foundation.dart';

import '../visit_review_view_model.dart';

class ExamStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;
  List<String> selectedExamOptions = [];
  List<Map<String, String>> examLocations = [];

  bool editedStep = false;

  ExamStepState({
    @required this.visitReviewViewModel,
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    VisitReviewData firestoreData = this.visitReviewViewModel.visitReviewData;
    if (firestoreData.examLocations != null &&
        firestoreData.examLocations.length > 0) {
      this.examLocations = firestoreData.examLocations;
      this.selectedExamOptions =
          firestoreData.examLocations.map((e) => e.keys.first).toList();

      if (minimumRequiredFieldsFilledOut) {
        visitReviewViewModel.addCompletedStep(
            step: VisitReviewSteps.ExamStep, setState: false);
      }
    }
  }

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

  //the value the provider enters in the text field
  //key is the exam and value is the location of the exam
  String getExamLocation(String exam) {
    List<Map<String, String>> locations =
        examLocations.where((element) => element.keys.first == exam).toList();
    if (locations.length > 0) {
      return locations.first.values.first;
    }
    return "";
  }

  String locationQuestion(String examOption) {
    return examOption.toLowerCase() == "other"
        ? "Enter custom location entry for \"Other\""
        : "What is the location of the $examOption? (Optional)";
  }

  void updateExamStepWith({
    List<String> selectedExamOptions,
    Map<String, String> locationMap,
  }) {
    this.editedStep = true;

    this.selectedExamOptions = selectedExamOptions ?? this.selectedExamOptions;
    if (locationMap != null) {
      int index = this
          .examLocations
          .indexWhere((element) => element.containsKey(locationMap.keys.first));
      if (index > -1) {
        this.examLocations[index] = locationMap;
      } else {
        if (locationMap != null) {
          this.examLocations.add(locationMap);
        }
      }
    }

    notifyListeners();
  }
}
