import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';

class EmailAssistantViewModel with ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  Consult consult;
  String email;
  List<String> reasonLabels = [
    'Coordinate an office visit',
    'Coordinate referral',
    'Pharmacy issue',
    'Upload patient note to EHR',
    'Other',
  ];
  String selectedVisit;
  bool boxChecked;
  bool isSubmitted;

  EmailAssistantViewModel({
    @required this.consult,
    @required this.firestoreDatabase,
    this.email,
    this.selectedVisit,
    this.reasonLabels,
    this.boxChecked,
    this.isSubmitted,
  });

  void updateWith({
    Consult consult,
    String email,
    String selectedVisit,
    bool boxChecked,
    bool isSubmitted,
  }) {
    this.consult = consult ?? this.consult;
    this.email = email ?? this.email;
    this.selectedVisit = selectedVisit ?? this.selectedVisit;
    this.boxChecked = boxChecked ?? boxChecked;
    this.isSubmitted = isSubmitted ?? isSubmitted;
    notifyListeners();
  }
}
