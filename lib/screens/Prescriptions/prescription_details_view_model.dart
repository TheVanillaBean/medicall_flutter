import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class PrescriptionDetailsViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;
  final AuthBase auth;
  final TreatmentOptions treatmentOptions;

  bool initialDateSet = false;

  String medicationName = '';
  String quantity = '';
  String refills = '';
  String form = '';
  String dose = '';
  String frequency = '';
  String instructions = '';

  final FocusNode medicationNameFocusNode = FocusNode();
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode refillsFocusNode = FocusNode();
  final FocusNode formFocusNode = FocusNode();
  final FocusNode doseFocusNode = FocusNode();
  final FocusNode frequencyFocusNode = FocusNode();
  final FocusNode instructionsFocusNode = FocusNode();

  @override
  void dispose() {
    medicationNameFocusNode.dispose();
    quantityFocusNode.dispose();
    refillsFocusNode.dispose();
    formFocusNode.dispose();
    doseFocusNode.dispose();
    frequencyFocusNode.dispose();
    instructionsFocusNode.dispose();
    super.dispose();
  }

  PrescriptionDetailsViewModel({
    @required this.database,
    @required this.userProvider,
    @required this.auth,
    @required this.treatmentOptions,
  }) {
    updateWithTreatmentModel();
  }

  void updateWithTreatmentModel() {
    this.medicationName =
        this.treatmentOptions.medicationName ?? this.medicationName;
    this.quantity = this.treatmentOptions.quantity ?? this.quantity;
    this.refills = this.treatmentOptions.refills ?? this.refills;
    this.form = this.treatmentOptions.form ?? this.form;
    this.dose = this.treatmentOptions.dose ?? this.dose;
    this.frequency = this.treatmentOptions.frequency ?? this.frequency;
    this.instructions = this.treatmentOptions.instructions ?? this.instructions;
  }

  void updateWith({
    String medicationName,
    String quantity,
    String refills,
    String form,
    String dose,
    String frequency,
    String instructions,
  }) {
    this.medicationName = medicationName ?? this.medicationName;
    this.quantity = quantity ?? this.quantity;
    this.refills = refills ?? this.refills;
    this.form = form ?? this.form;
    this.dose = dose ?? this.dose;
    this.frequency = frequency ?? this.frequency;
    this.instructions = instructions ?? this.instructions;
    notifyListeners();
  }

  void updateMedicationName(String medicationName) =>
      updateWith(medicationName: medicationName);
  void updateQuantity(String quantity) => updateWith(quantity: quantity);
  void updateRefills(String refills) => updateWith(refills: refills);
  void updateForm(String form) => updateWith(form: form);
  void updateDose(String dose) => updateWith(dose: dose);
  void updateFrequency(String frequency) => updateWith(frequency: frequency);
  void updateInstructions(String instructions) =>
      updateWith(instructions: instructions);
}
