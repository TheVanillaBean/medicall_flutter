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
  });

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
