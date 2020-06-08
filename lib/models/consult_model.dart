import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class Consult {
  final String providerId;
  final String patientId;
  final String symptom;
  final String price;
  final DateTime date;
  final String state;

  Consult({
    @required this.providerId,
    @required this.symptom,
    this.patientId,
    this.price = "49",
    this.date,
    this.state,
  });

  factory Consult.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    Timestamp dateTimeStamp = data["date"];

    final String providerId = data['provider_id'];
    final String patientId = data['patient_id'];
    final String symptom = data['symptom'];
    final String price = data['price'];
    final DateTime date = DateTime.parse(dateTimeStamp.toDate().toString());
    final String state = data['state'];

    return Consult(
      providerId: providerId,
      patientId: patientId,
      symptom: symptom,
      price: price,
      date: date,
      state: state,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'patient_id': patientId,
      'symptom': symptom,
      'price': price,
      'date': date,
      'state': state,
    };
  }

  @override
  String toString() =>
      'provider_id: $providerId, patient_id: $patientId, symptom: $symptom';
}
