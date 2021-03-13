import 'package:Medicall/models/insurance_info.dart';
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
  ReferralRequested,
}

extension EnumParser on String {
  ConsultStatus toConsultStatus() {
    return ConsultStatus.values.firstWhere(
      (e) => e.toString().toLowerCase() == 'ConsultStatus.$this'.toLowerCase(),
      orElse: () => null,
    ); //return null if not found
  }
}

abstract class ChatClosedKeys {
  static const REASON = "reason";
  static const CONTACT_PATIENT = "contact_patient";
}

abstract class VisitTroubleLabels {
  static const Poor_Quality = "Inadequate/poor quality information";
  static const Redirect = "Redirect patient to an office visit";
  static const Patient_Satisfaction = "Patient satisfaction concern";
  static const Inappropriate_Conduct = "Inappropriate patient conduct";
  static const Other = "Other";
  static const allReasons = [
    Poor_Quality,
    Redirect,
    Patient_Satisfaction,
    Inappropriate_Conduct,
    Other,
  ];
}

abstract class VisitIssueKeys {
  static const ISSUE = "issue";
  static const REASON = "reason";
  static const ASSISTANT_REACH_OUT = "assistant_reach_out";
  static const BRIEF_NOTE = "note";
  static const EXPLANATION = "explanation";
  static const SUGGESTIONS = "suggestion";
  static const MEDICALL_ADDRESS_ISSUE = "medicall_address_issue";
  static const SHOULD_REFUND = "should_refund";
}

class Consult {
  String uid;
  final String providerId;
  String symptom;
  int price;
  final DateTime date;
  String patientId;
  ConsultStatus state;
  List<Question> questions;
  bool providerReclassified;
  String reclassifiedVisit;
  String coupon;
  int providerReviewNotifications;
  int providerMessageNotifications;
  int patientReviewNotifications;
  int patientMessageNotifications;
  bool assistantEmailed;
  Map<String, dynamic> chatClosed;
  Map<String, dynamic> visitIssue;
  bool insurancePayment;
  InsuranceInfo insuranceInfo;

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
    this.price,
    this.date,
    this.state,
    this.questions = const <Question>[],
    this.providerReclassified = false,
    this.reclassifiedVisit = '',
    this.providerUser,
    this.patientUser,
    this.coupon,
    this.patientMessageNotifications = 0,
    this.patientReviewNotifications = 0,
    this.providerMessageNotifications = 0,
    this.providerReviewNotifications = 0,
    this.assistantEmailed = false,
    this.chatClosed,
    this.visitIssue,
    this.insurancePayment = false,
    this.insuranceInfo,
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
    final String coupon = data['coupon_code'] ?? null;

    final int patientMessageNotifications =
        data['patient_message_notifications'] ?? 0;
    final int patientReviewNotifications =
        data['patient_review_notifications'] ?? 0;
    final int providerReviewNotifications =
        data['provider_review_notifications'] ?? 0;
    final int providersMessageNotifications =
        data['provider_message_notifications'] ?? 0;

    //is set whenever paubox cloud function is called, so not in toMap
    final bool assistantEmailed = data['assistant_emailed'] ?? false;

    Map<String, dynamic> chatClosed;
    if (data["chat_closed"] != null) {
      chatClosed = (data["chat_closed"] as Map).map(
        (key, value) => MapEntry(key as String, value as dynamic),
      );
    }

    Map<String, dynamic> visitIssue;
    if (data["visit_issue"] != null) {
      visitIssue = (data["visit_issue"] as Map).map(
        (key, value) => MapEntry(key as String, value as dynamic),
      );
    }

    final bool insurancePayment = data['insurance_payment'] ?? false;

    InsuranceInfo insuranceInfo;
    if (insurancePayment) {
      insuranceInfo = InsuranceInfo.fromMap(data['insurance_info']);
    }

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
      coupon: coupon,
      patientMessageNotifications: patientMessageNotifications,
      patientReviewNotifications: patientReviewNotifications,
      providerMessageNotifications: providersMessageNotifications,
      providerReviewNotifications: providerReviewNotifications,
      assistantEmailed: assistantEmailed,
      chatClosed: chatClosed,
      visitIssue: visitIssue,
      insurancePayment: insurancePayment,
      insuranceInfo: insuranceInfo,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> baseToMap = {
      'provider_id': providerId,
      'patient_id': patientId,
      'symptom': symptom,
      'price': price,
      'date': date,
      'state': EnumToString.convertToString(state),
      'provider_reclassified': providerReclassified,
      'patient_message_notifications': patientMessageNotifications,
      'patient_review_notifications': patientReviewNotifications,
      'provider_review_notifications': providerReviewNotifications,
      'provider_message_notifications': providerMessageNotifications,
      'insurance_payment': insurancePayment
    };
    if (providerReclassified) {
      baseToMap.addAll({
        'reclassified_visit': reclassifiedVisit,
      });
    }
    if (coupon != null) {
      baseToMap.addAll({
        'coupon_code': coupon,
      });
    }
    if (chatClosed != null) {
      baseToMap.addAll({
        'chat_closed': chatClosed,
      });
    }
    if (visitIssue != null) {
      baseToMap.addAll({
        'visit_issue': visitIssue,
      });
    }
    if (insurancePayment) {
      baseToMap.addAll({
        'insurance_info': insuranceInfo.toMap(),
      });
    }
    return baseToMap;
  }

  @override
  String toString() =>
      'provider_id: $providerId, patient_id: $patientId, symptom: $symptom';
}
