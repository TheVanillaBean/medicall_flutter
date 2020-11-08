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
  }) {
    this.medicationName = this.treatmentOptions.medicationName;
    this.quantity = this.treatmentOptions.quantity;
    this.refills = this.treatmentOptions.refills;
    this.form = this.treatmentOptions.form;
    this.dose = this.treatmentOptions.dose;
    this.frequency = this.treatmentOptions.frequency;
    this.instructions = this.treatmentOptions.instructions;
  }

  bool get allFieldsValidated {
    return inputValidator.isValid(this.medicationName) &&
        inputValidator.isValid(this.quantity) &&
        inputValidator.isValid(this.refills) &&
        inputValidator.isValid(this.form) &&
        inputValidator.isValid(this.dose) &&
        inputValidator.isValid(this.frequency) &&
        inputValidator.isValid(this.instructions);
  }

  //if current treatment is a custom selected treatment
  bool get isCurrentTreatmentOther {
    return treatmentOptions.medicationName.toLowerCase() == "other";
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
