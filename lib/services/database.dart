import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/coupon.dart';
import 'package:Medicall/models/questionnaire/screening_questions_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'firestore_path.dart';

abstract class Database {
  Future<void> setUser(MedicallUser user);
  Stream<MedicallUser> userStream(USER_TYPE userType, uid);
  Future<String> saveConsult({String consultId, Consult consult});
  Stream<Consult> consultStream({String consultId});
  Future<void> saveQuestionnaire(
      {String consultId, ScreeningQuestions screeningQuestions});
  Future<void> saveMedicalHistory(
      {String userId, ScreeningQuestions screeningQuestions});
  Stream<List<Consult>> getPendingConsultsForProvider(String uid);
  Stream<List<Consult>> getConsultsForPatient(String uid, String state);
  Stream<List<Consult>> getConsultsForProvider(String uid);
  Stream<List<Consult>> getActiveConsultsForPatient(String uid);
  Future<ConsultReviewOptions> consultReviewOptions({String symptomName});
  Future<DiagnosisOptions> consultReviewDiagnosisOptions(
      {String symptomName, String diagnosis});
  Future<ScreeningQuestions> consultQuestionnaire({String consultId});
  Future<ScreeningQuestions> medicalHistory({String uid});
  Stream<List<Consult>> getTotalConsultsForPatient(String uid);
  Future<void> saveVisitReview(
      {String consultId, VisitReviewData visitReviewData});
  Future<void> savePrescriptions(
      {String consultId, List<TreatmentOptions> treatmentOptions});
  Stream<VisitReviewData> visitReviewStream({String consultId});
  Future<List<ScreeningQuestions>> getScreeningQuestions({String symptomName});
  Future<List<PaymentMethod>> getUserCardSources(String uid);
  Future<Coupon> getCoupon(String code);
}

class FirestoreDatabase implements Database {
  final _service = FirestoreService.instance;

  @override
  Future<void> setUser(MedicallUser user) => _service.setData(
        path: FirestorePath.user(user.uid),
        data: user.type == USER_TYPE.PATIENT
            ? (user as PatientUser).toMap()
            : (user as ProviderUser).toMap(),
        merge: true,
      );

  @override
  Stream<MedicallUser> userStream(USER_TYPE userType, uid) =>
      _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => MedicallUser.fromMap(
            userType: userType, data: data, uid: documentId),
      );

  @override
  Future<String> saveConsult({String consultId, Consult consult}) async {
    String cid =
        consultId ?? FirebaseFirestore.instance.collection("consults").doc().id;
    await _service.setData(
      path: FirestorePath.consult(cid),
      data: consult.toMap(),
      merge: true,
    );
    return cid;
  }

  @override
  Stream<Consult> consultStream({String consultId}) => _service.documentStream(
        path: FirestorePath.consult(consultId),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  @override
  Future<void> saveQuestionnaire(
          {String consultId, ScreeningQuestions screeningQuestions}) =>
      _service.setData(
        path: FirestorePath.questionnaire(consultId),
        data: screeningQuestions.toMap(),
      );

  @override
  Future<void> saveMedicalHistory(
          {String userId, ScreeningQuestions screeningQuestions}) =>
      _service.setData(
        path: FirestorePath.medicalHistory(userId),
        data: screeningQuestions.toMap(),
        merge: true,
      );

  @override
  Stream<List<Consult>> getPendingConsultsForProvider(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query
            .where('provider_id', isEqualTo: uid)
            .where("state", whereIn: [
              "PendingReview",
              "InReview",
              "Completed",
              "Signed",
            ])
            .orderBy("date", descending: true)
            .where(
              "date",
              isGreaterThanOrEqualTo: DateTime.now().subtract(
                Duration(days: 7),
              ),
            )
            .limit(5),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  @override
  Stream<List<Consult>> getConsultsForPatient(String uid, String state) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query
            .where(
              'patient_id',
              isEqualTo: uid,
            )
            .where('state', isEqualTo: state),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  @override
  Stream<List<Consult>> getConsultsForProvider(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query.where('provider_id', isEqualTo: uid),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  @override
  Stream<List<Consult>> getActiveConsultsForPatient(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query
            .where('patient_id', isEqualTo: uid)
            .orderBy("date", descending: true)
            .where(
              "date",
              isGreaterThanOrEqualTo: DateTime.now().subtract(
                Duration(days: 7),
              ),
            )
            .limit(3),
        sort: (lhs, rhs) => rhs.date.compareTo(lhs.date),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  @override
  Future<ConsultReviewOptions> consultReviewOptions({String symptomName}) =>
      _service
          .documentStream(
            path: FirestorePath.consultReviewOptions(symptomName),
            builder: (data, documentId) =>
                ConsultReviewOptions.fromMap(data, documentId),
          )
          .first;

  @override
  Future<DiagnosisOptions> consultReviewDiagnosisOptions(
          {String symptomName, String diagnosis}) =>
      _service
          .documentStream(
            path: FirestorePath.consultReviewOptionsDiagnosis(
                symptomName, diagnosis),
            builder: (data, documentId) =>
                DiagnosisOptions.fromMap(data['review-options'], diagnosis),
          )
          .first;

  @override
  Future<ScreeningQuestions> consultQuestionnaire({String consultId}) =>
      _service
          .documentStream(
            path: FirestorePath.questionnaire(consultId),
            builder: (data, documentId) =>
                ScreeningQuestions.fromMap(data, documentId),
          )
          .first;

  @override
  Future<ScreeningQuestions> medicalHistory({String uid}) => _service
      .documentStream(
        path: FirestorePath.medicalHistory(uid),
        builder: (data, documentId) =>
            ScreeningQuestions.fromMap(data, documentId),
      )
      .first;

  @override
  Stream<List<Consult>> getTotalConsultsForPatient(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query.where('patient_id', isEqualTo: uid),
        sort: (lhs, rhs) => rhs.date.compareTo(lhs.date),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  @override
  Future<void> saveVisitReview(
      {String consultId, VisitReviewData visitReviewData}) async {
    await _service.setData(
      path: FirestorePath.visitReview(consultId),
      data: visitReviewData.toMap(),
      merge: false,
    );
  }

  @override
  Future<void> savePrescriptions(
      {String consultId, List<TreatmentOptions> treatmentOptions}) async {
    for (TreatmentOptions treatmentOptions in treatmentOptions) {
      String prescriptionId = FirebaseFirestore.instance
          .collection("consults")
          .doc(consultId)
          .collection("prescriptions")
          .doc()
          .id;

      await _service.setData(
        path: FirestorePath.prescriptions(consultId, prescriptionId),
        data: treatmentOptions.toMap(),
        merge: false,
      );
    }
  }

  @override
  Stream<VisitReviewData> visitReviewStream({String consultId}) =>
      _service.documentStream(
        path: FirestorePath.visitReview(consultId),
        builder: (data, documentId) =>
            VisitReviewData.fromMap(data, documentId),
      );

  @override
  Future<List<ScreeningQuestions>> getScreeningQuestions(
          {String symptomName}) =>
      _service
          .collectionStream(
            path: FirestorePath.screeningQuestions(symptomName),
            builder: (data, documentId) =>
                ScreeningQuestions.fromMap(data, documentId),
          )
          .first;

  @override
  Future<List<PaymentMethod>> getUserCardSources(String uid) async {
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'listPaymentMethods')
          ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call();

    List<PaymentMethod> paymentList = List<PaymentMethod>();

    if (result.data['data'].length > 0) {
      for (var card in result.data['data']) {
        PaymentMethod method = PaymentMethod.fromJson(card);
        method.customerId = uid;
        paymentList.add(method);
      }
    }

    return Future<List<PaymentMethod>>.value(paymentList);
  }

  @override
  Future<Coupon> getCoupon(String code) => _service
      .documentStream(
          path: FirestorePath.coupon(code),
          builder: (data, documentId) => Coupon.fromMap(data, documentId))
      .first;
}
