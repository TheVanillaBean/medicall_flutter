import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/foundation.dart';

class EducationalStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;

  List<String> selectedEducationalOptions = [];
  bool otherSelected;
  String otherEducationalOption;

  EducationalStepState({
    @required this.visitReviewViewModel,
    this.otherSelected = false,
    this.otherEducationalOption = "",
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    VisitReviewData firestoreData = this.visitReviewViewModel.visitReviewData;
    if (firestoreData.educationalOptions.length > 0) {
      firestoreData.educationalOptions.forEach((element) {
        String eduOption = element.keys.first;
        this.selectedEducationalOptions.add(eduOption);
        if (eduOption == "Other") {
          this.otherSelected = true;
          otherEducationalOption = element.values.first;
        }
      });

      if (minimumRequiredFieldsFilledOut) {
        visitReviewViewModel.addCompletedStep(
            step: VisitReviewSteps.EducationalContentStep, setState: false);
      }
    }
  }

  bool get minimumRequiredFieldsFilledOut {
    if (this.otherSelected) {
      return this.otherEducationalOption.length > 0;
    }
    return this.selectedEducationalOptions.length > 0;
  }

  void updateEducationalInformation({
    List<String> selectedEducationalOptions,
    String otherEducationalOption,
  }) {
    this.selectedEducationalOptions =
        selectedEducationalOptions ?? this.selectedEducationalOptions;
    this.otherEducationalOption =
        otherEducationalOption ?? this.otherEducationalOption;
    if (this.selectedEducationalOptions.contains("Other")) {
      this.otherSelected = true;
    } else {
      this.otherSelected = false;
      this.otherEducationalOption = "";
    }

    notifyListeners();
  }
}
