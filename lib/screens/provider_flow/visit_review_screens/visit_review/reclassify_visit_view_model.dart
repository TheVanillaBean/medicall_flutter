import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';

class ReclassifyVisitViewModel with ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final Consult consult;

  bool reclassifyVisit;
  String visitClassification;
  int selectedItemIndex = 0;
  List<String> totalSymptoms;

  ReclassifyVisitViewModel({
    @required this.firestoreDatabase,
    @required this.consult,
    @required this.totalSymptoms,
    this.reclassifyVisit = false,
    this.visitClassification = '',
    this.selectedItemIndex = 0,
  }) {
    this.setClassifyFromPrevData();
  }

  bool get minimumRequiredFieldsFilledOut {
    if (reclassifyVisit) {
      return this.visitClassification.length > 0;
    }
    return true;
  }

  void setClassifyFromPrevData() {
    if (this.consult.providerReclassified) {
      int selectedIndex = 0;
      int symptomIndex = this
          .totalSymptoms
          .indexWhere((element) => element == this.consult.reclassifiedVisit);
      if (symptomIndex > -1) {
        selectedIndex = symptomIndex;
      }
      updateClassifyStepWith(
        reclassify: true,
        visitClassification: this.consult.reclassifiedVisit,
        selectedItemIndex: selectedIndex,
      );
    } else {
      updateClassifyStepWith(
          reclassify: false, visitClassification: this.consult.symptom);
    }
  }

  Future<void> updateClassifyStepWith({
    bool reclassify,
    String visitClassification,
    int selectedItemIndex,
  }) async {
    this.selectedItemIndex = selectedItemIndex ?? this.selectedItemIndex;
    this.visitClassification = this.totalSymptoms[this.selectedItemIndex];
    this.reclassifyVisit = reclassify ?? this.reclassifyVisit;
    this.visitClassification = visitClassification ?? this.visitClassification;
    notifyListeners();
  }

  Future<void> updateConsult() async {
    this.consult.providerReclassified = true;
    this.consult.reclassifiedVisit = this.visitClassification;
    await firestoreDatabase.saveConsult(
        consultId: consult.uid, consult: consult);
  }
}
