import 'package:Medicall/models/consult-review/treatment_options.dart';

class TreatmentNoteStepState {
  bool currentlySelectedIsOther = false;

  List<TreatmentOptions> selectedTreatmentOptions = [];

  bool get minimumRequiredFieldsFilledOut {
    return this.selectedTreatmentOptions.length > 0;
  }
}
