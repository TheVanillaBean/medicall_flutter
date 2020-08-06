import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentOptions {
  String dose;
  String form;
  String frequency;
  String instructions;
  String medicationName;
  String quantity;
  String refills;
  DateTime date;

  TreatmentOptions({
    this.dose,
    this.form,
    this.frequency,
    this.instructions,
    this.medicationName,
    this.quantity,
    this.refills,
    this.date,
  });

  factory TreatmentOptions.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Timestamp dateTimeStamp = data["date"] ?? Timestamp.now();

    final String medicationName = data['medication_name'] as String ?? "";
    final String dose = data['dose'] as String ?? "";
    final String form = data['form'] as String ?? "";
    final String frequency = data['frequency'] as String ?? "";
    final String instructions = data['instructions'] as String ?? "";
    final String quantity = data['quantity'] as String ?? "";
    final String refills = data['refills'] as String ?? "";

    final DateTime date = DateTime.parse(dateTimeStamp.toDate().toString());

    return TreatmentOptions(
      medicationName: medicationName,
      dose: dose,
      form: form,
      frequency: frequency,
      instructions: instructions,
      quantity: quantity,
      refills: refills,
      date: date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'medication_name': medicationName,
      'dose': dose,
      'form': form,
      'frequency': frequency,
      'instructions': instructions,
      'quantity': quantity,
      'refills': refills,
      'date': date,
    };
  }
}
