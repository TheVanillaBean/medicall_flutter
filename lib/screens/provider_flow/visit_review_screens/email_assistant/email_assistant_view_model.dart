import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';

class EmailAssistantViewModel with EmailAndPasswordValidators, ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  Consult consult;
  String email;
  List<String> selectReasons = [
    'Coordinate an office visit',
    'Coordinate referral',
    'Pharmacy issue',
    'Upload patient note to EHR',
    'Other',
  ];
  String selectedReason;
  bool boxChecked;
  bool isSubmitted;

  EmailAssistantViewModel({
    @required this.consult,
    @required this.firestoreDatabase,
    this.email = "",
    this.selectedReason = "",
    this.boxChecked = false,
    this.isSubmitted = false,
  });

  bool get canSubmit {
    return emailValidator.isValid(email) && !isSubmitted;
  }

  void updateWith({
    Consult consult,
    String email,
    String selectedReason,
    bool boxChecked,
    bool isSubmitted,
  }) {
    this.consult = consult ?? this.consult;
    this.email = email ?? this.email;
    this.selectedReason = selectedReason ?? this.selectedReason;
    this.boxChecked = boxChecked ?? boxChecked;
    this.isSubmitted = isSubmitted ?? isSubmitted;
    notifyListeners();
  }
}
