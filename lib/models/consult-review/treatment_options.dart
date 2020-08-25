import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum TreatmentStatus {
  PendingPayment,
  Paid,
}

extension EnumParser on String {
  TreatmentStatus toTreatmentStatus() {
    return TreatmentStatus.values.firstWhere(
      (e) =>
          e.toString().toLowerCase() == 'TreatmentStatus.$this'.toLowerCase(),
      orElse: () => null,
    ); //return null if not found
  }
}

class TreatmentOptions {
  String dose;
  String form;
  String frequency;
  String instructions;
  String medicationName;
  String quantity;
  String refills;
  DateTime date;
  TreatmentStatus status;
  int price;

  TreatmentOptions({
    this.dose,
    this.form,
    this.frequency,
    this.instructions,
    this.medicationName,
    this.quantity,
    this.refills,
    this.date,
    this.status = TreatmentStatus.PendingPayment,
    this.price,
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
    final int price = data['price'] as int ?? -1;
    final TreatmentStatus state =
        (data['state'] as String).toTreatmentStatus() ??
            TreatmentStatus.PendingPayment;

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
      status: state,
      price: price,
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
      'price': price,
      'state': EnumToString.parse(status),
    };
  }
}
