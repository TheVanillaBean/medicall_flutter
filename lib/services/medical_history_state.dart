import 'package:flutter/material.dart';

class MedicalHistoryState with ChangeNotifier {
  MedicalHistoryState();

  bool _newMedicalHistory = false;

  setnewMedicalHistory(bool val) {
    _newMedicalHistory = val;
    notifyListeners();
  }

  bool getnewMedicalHistory() {
    return _newMedicalHistory;
  }
}
