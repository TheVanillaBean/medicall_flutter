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

  List<String> get medicationNames {
    return this
        .visitReviewViewModel
        .diagnosisOptions
        .treatments
        .map((t) => t.medicationName)
        .toList();
  }

  List<String> get selectedMedicationNames {
    return this.selectedTreatmentOptions.map((e) => e.medicationName).toList();
  }

  TreatmentOptions selectedTreatment(int index) {
    TreatmentOptions treatmentOptions =
        this.visitReviewViewModel.diagnosisOptions.treatments[index];
    return selectedTreatmentOptions
        .where((element) =>
            element.medicationName == treatmentOptions.medicationName)
        .single;
  }

  bool isSelectedPrescription(int index, String medicationName) {
    //check if selected treatments contain this treatment
    int selectedIndex = this
        .selectedTreatmentOptions
        .indexWhere((element) => element.medicationName == medicationName);
    if (selectedIndex > -1) {
      TreatmentOptions treatmentOptions =
          this.selectedTreatmentOptions[selectedIndex];
      return !treatmentOptions.notAPrescription;
    }
    return false;
  }

  void updateTreatment({TreatmentOptions treatmentOptions}) {
    int index = this.selectedTreatmentOptions.indexWhere(
        (element) => element.medicationName == treatmentOptions.medicationName);
    if (index > -1) {
      this.selectedTreatmentOptions[index] = treatmentOptions;
      notifyListeners();
    }
  }

  void addTreatment({TreatmentOptions treatmentOptions}) {
    this.selectedTreatmentOptions.add(treatmentOptions);
    notifyListeners();
  }

  void removeTreatment({TreatmentOptions treatmentOptions}) {
    this.selectedTreatmentOptions.remove(treatmentOptions);
    notifyListeners();
  }
}
