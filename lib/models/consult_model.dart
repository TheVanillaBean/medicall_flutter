import 'package:Medicall/models/questionnaire/question_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
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
  String symptom;
  final int price;
  final DateTime date;
  String patientId;
  ConsultStatus state;
  List<Question> questions;
  bool providerReclassified;
  String reclassifiedVisit;
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
    this.providerReclassified = false,
    this.reclassifiedVisit = '',
    this.providerUser,
    this.patientUser,
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
    final bool providerReclassified =
        data['provider_reclassified'] as bool ?? false;
    final String reclassifiedVisit = data['reclassified_visit'] as String ?? '';

    return Consult(
      uid: documentId,
      providerId: providerId,
      patientId: patientId,
      symptom: symptom,
      price: price,
      date: date,
      state: state,
      providerReclassified: providerReclassified,
      reclassifiedVisit: reclassifiedVisit,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> baseToMap = {
      'provider_id': providerId,
      'patient_id': patientId,
      'symptom': symptom,
      'price': price,
      'date': date,
      'state': EnumToString.parse(state),
      'provider_reclassified': providerReclassified,
    };
    if (providerReclassified) {
      baseToMap.addAll({
        'reclassified_visit': reclassifiedVisit,
      });
    }
    return baseToMap;
  }

  @override
  String toString() =>
      'provider_id: $providerId, patient_id: $patientId, symptom: $symptom';
}
