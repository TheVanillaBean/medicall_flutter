import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/steps_view_models/patient_note_step_state.dart';
import 'package:flutter/cupertino.dart';

class EditNoteViewModel with ChangeNotifier {
  bool noteEdited = false;

  PatientNoteSection section;
  String sectionTitle;
  Map<String, dynamic> templateSection = {};
  Map<String, dynamic> editedSection = {};

  EditNoteViewModel({
    @required this.section,
    @required this.sectionTitle,
    @required this.templateSection,
    @required this.editedSection,
  });

  void updateEditSectionCheckboxesWith(String key, bool isChecked) {
    if (isChecked) {
      this.editedSection[key] = this.templateSection[key];
    } else {
      this.editedSection.remove(key);
    }
    noteEdited = true;
    notifyListeners();
  }

  void updateEditSectionWith(String key, String value) {
    this.editedSection[key] = value;
    noteEdited = true;
    notifyListeners();
  }
}
