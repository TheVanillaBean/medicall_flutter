import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

enum ConsultStatus {
  PendingPayment,
  PendingReview,
  InReview,
  Completed,
  Signed,
}

extension EnumParser on String {
  ConsultStatus toConsultStatus() {
    return ConsultStatus.values.firstWhere(
      (e) => e.toString().toLowerCase() == 'ConsultStatus.$this'.toLowerCase(),
      orElse: () => null,
    ); //return null if not found
  }
}

class Consult {
  String uid;
  final String providerId;
  final String symptom;
  final int price;
  final DateTime date;
  String patientId;
  ConsultStatus state;
  List<Question> questions;

  //not serialized
  PatientUser patientUser;
  ProviderUser providerUser;

  String get parsedDate {
    final f = DateFormat('E d MMM, h:mma');
    return f.format(this.date);
  }

  Consult({
    @required this.providerId,
    @required this.symptom,
    this.uid,
    this.patientId,
    this.price = 49,
    this.date,
    this.state,
    this.questions = const <Question>[],
  });

  factory Consult.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    Timestamp dateTimeStamp = data["date"];

    final String providerId = data['provider_id'];
    final String patientId = data['patient_id'];
    final String symptom = data['symptom'];
    final int price = data['price'];
    final DateTime date = DateTime.parse(dateTimeStamp.toDate().toString());
    final ConsultStatus state =
        (data['state'] as String).toConsultStatus() ?? null;
//    final List<Question> questions = (data['screening_questions'] as List ?? [])
//        .map((v) => Question.fromMap(v))
//        .toList();

    return Consult(
      uid: documentId,
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
      'state': EnumToString.parse(state),
//      "screening_questions": questions.map((q) => q.toMap()),
    };
  }

  @override
  String toString() =>
      'provider_id: $providerId, patient_id: $patientId, symptom: $symptom';
}
