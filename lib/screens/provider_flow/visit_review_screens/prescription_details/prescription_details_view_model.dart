import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';

class PrescriptionDetailsViewModel with ChangeNotifier, PrescriptionValidator {
  final FirestoreDatabase database;
  final UserProvider userProvider;
  final AuthBase auth;
  final TreatmentOptions treatmentOptions;

  bool treatmentUpdated = false;

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
  });

  bool get allFieldsValidated {
    if (this.treatmentOptions.quantity.length == 0 &&
        this.treatmentOptions.dose.length == 0) {
      return true;
    }
    return inputValidator.isValid(this.treatmentOptions.medicationName) &&
        inputValidator.isValid(this.treatmentOptions.quantity) &&
        inputValidator.isValid(this.treatmentOptions.refills) &&
        inputValidator.isValid(this.treatmentOptions.form) &&
        inputValidator.isValid(this.treatmentOptions.dose) &&
        inputValidator.isValid(this.treatmentOptions.frequency) &&
        inputValidator.isValid(this.treatmentOptions.instructions);
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
    this.treatmentOptions.medicationName =
        medicationName ?? this.treatmentOptions.medicationName;
    this.treatmentOptions.quantity = quantity ?? this.treatmentOptions.quantity;
    this.treatmentOptions.refills = refills ?? this.treatmentOptions.refills;
    this.treatmentOptions.form = form ?? this.treatmentOptions.form;
    this.treatmentOptions.dose = dose ?? this.treatmentOptions.dose;
    this.treatmentOptions.frequency =
        frequency ?? this.treatmentOptions.frequency;
    this.treatmentOptions.instructions =
        instructions ?? this.treatmentOptions.instructions;
    treatmentUpdated = true;
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
