import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:flutter/foundation.dart';

class TreatmentNoteStepState with ChangeNotifier {
  VisitReviewViewModel visitReviewViewModel;

  List<TreatmentOptions> selectedTreatmentOptions = [];

  bool editedStep = false;

  TreatmentNoteStepState({
    @required this.visitReviewViewModel,
  }) {
    this.initFromFirestore();
  }

  void initFromFirestore() {
    VisitReviewData firestoreData = this.visitReviewViewModel.visitReviewData;
    if (firestoreData.treatmentOptions != null &&
        firestoreData.treatmentOptions.length > 0) {
      this.selectedTreatmentOptions = firestoreData.treatmentOptions;

      if (minimumRequiredFieldsFilledOut) {
        visitReviewViewModel.addCompletedStep(
            step: VisitReviewSteps.TreatmentStep, setState: false);
      }
    }
  }

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
      this.editedStep = true;
      this.selectedTreatmentOptions[index] = treatmentOptions;
      notifyListeners();
    }
  }

  void addTreatment({TreatmentOptions treatmentOptions}) {
    this.editedStep = true;
    this.selectedTreatmentOptions.add(treatmentOptions);
    notifyListeners();
  }

  void removeTreatment({TreatmentOptions treatmentOptions}) {
    this.editedStep = true;
    this.selectedTreatmentOptions.remove(treatmentOptions);
    notifyListeners();
  }
}
