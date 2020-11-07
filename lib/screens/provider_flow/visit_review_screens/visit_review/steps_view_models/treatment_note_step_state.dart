import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/foundation.dart';

class TreatmentNoteStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;

  bool currentlySelectedIsOther = false;
  List<TreatmentOptions> selectedTreatmentOptions = [];

  TreatmentNoteStepState({
    @required this.visitReviewViewModel,
  });

  bool get minimumRequiredFieldsFilledOut {
    return this.selectedTreatmentOptions.length > 0;
  }

  void removeTreatmentOption({TreatmentOptions selectedTreatment}) {
    this.selectedTreatmentOptions.remove(selectedTreatment);
    notifyListeners();
  }

  void updateTreatmentStepWith({TreatmentOptions selectedTreatment}) {
    if (this
            .selectedTreatmentOptions
            .where((element) =>
                element.medicationName == selectedTreatment.medicationName)
            .toList()
            .length ==
        0) {
      this.selectedTreatmentOptions.add(selectedTreatment);
    } else {
      int index = this.selectedTreatmentOptions.indexWhere((element) =>
          element.medicationName == selectedTreatment.medicationName);
      if (index > -1) {
        this.selectedTreatmentOptions[index] = selectedTreatment;
      }
    }

    //this determines if the diagnosis list already has this medication
    int index = this
        .visitReviewViewModel
        .diagnosisOptions
        .treatments
        .indexWhere((element) =>
            element.medicationName == selectedTreatment.medicationName);

    if (index == -1) {
      //this is the "other" option
      this.visitReviewViewModel.diagnosisOptions.treatments.last =
          selectedTreatment;
    }

    notifyListeners();
  }

  void deselectTreatmentStep(TreatmentOptions selectedTreatment) {
    this.selectedTreatmentOptions.removeWhere(
          (element) =>
              element.medicationName == selectedTreatment.medicationName,
        );
    notifyListeners();
  }
}
