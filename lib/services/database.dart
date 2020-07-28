import 'dart:io';

import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/diagnosis_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/History/Detail/history_detail_state.dart';
import 'package:Medicall/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:stripe_payment/stripe_payment.dart';

import 'firestore_path.dart';

abstract class Database {
  Future<void> setUser(User user);
  Future getConsultDetail(DetailedHistoryState detailedHistoryState);
  Stream<QuerySnapshot> getConsultPrescriptions(consultId);
  Future<void> getPatientDetail(User medicallUser);
  Future<void> setPrescriptionPayment(state, shipTo, shippingAddress);
  Future<void> updatePrescription(consultFormKey);
  addUserMedicalHistory(User medicallUser);
  getUserMedicalHistory(User medicallUser);
  getSymptoms(User medicallUser);
  getPatientMedicalHistory(User medicallUser);
  getConsultQuestions();
  updatePatientUnreadChat(bool reset);
  updateProviderUnreadChat(bool reset);
  Stream<QuerySnapshot> getAllProviders();
  Future<DocumentSnapshot> getMedicalHistoryQuestions();
  Future getDiagnosisQuestions(String type);
  Future<void> setDiagnosisQuestions(questions);
  Stream getAllUsers();
  Stream getConsultChat();
  saveConsultChatImage(User _medicallUser, File chatMedia);
  createNewConsultChatMsg(ChatMessage message);
  Stream getUserHistoryStream(User medicallUser);
  Future<QuerySnapshot> getUserSources({@required String uid});
  Future<void> addConsult(context, newConsult, extImageProvider,
      {@required User medicallUser});
  updateConsultStatus(Choice choice, String uid);
  sendChatMsg(content, {@required String uid});
  Future<List<PaymentMethod>> getUserCardSources(String uid);
  String consultChatImageUrl;
  DocumentSnapshot consultSnapshot;
  DocumentReference consultRef;
  Map<String, dynamic> consultStateData;
  bool isDone;
  User patientDetail;
  bool hasPayment;
  var userMedicalRecord;
  List<DocumentSnapshot> userHistory;
  ConsultData newConsult;
  var consultQuestions;
}

class FirestoreDatabase implements Database {
  final _service = FirestoreService.instance;

  String uid;
  @override
  DocumentSnapshot consultSnapshot;
  @override
  DocumentReference consultRef;
  @override
  Map<String, dynamic> consultStateData;
  @override
  bool isDone;
  @override
  User patientDetail;
  @override
  bool hasPayment;
  @override
  var userMedicalRecord;
  @override
  List<DocumentSnapshot> userHistory;
  @override
  ConsultData newConsult;
  @override
  var consultQuestions;
  @override
  String consultChatImageUrl;

  @override
  Future<void> setUser(User user) => _service.setData(
        path: FirestorePath.user(user.uid),
        data: user.type == USER_TYPE.PATIENT
            ? (user as PatientUser).toMap()
            : (user as ProviderUser).toMap(),
        merge: true,
      );

  Stream<User> userStream(USER_TYPE userType, uid) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) =>
            User.fromMap(userType: userType, data: data, uid: documentId),
      );

  Future<String> saveConsult({String consultId, Consult consult}) async {
    String cid = consultId ??
        Firestore.instance.collection("consults").document().documentID;
    await _service.setData(
      path: FirestorePath.consult(cid),
      data: consult.toMap(),
      merge: true,
    );
    return cid;
  }

  Stream<Consult> consultStream({String consultId}) => _service.documentStream(
        path: FirestorePath.consult(consultId),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  Future<void> saveQuestionnaire(
          {String consultId, ScreeningQuestions screeningQuestions}) =>
      _service.setData(
        path: FirestorePath.questionnaire(consultId),
        data: screeningQuestions.toMap(),
      );

  Stream<List<Consult>> getPendingConsultsForProvider(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) =>
            query.where('provider_id', isEqualTo: uid).where("state", whereIn: [
          EnumToString.parse(ConsultStatus.PendingReview),
          EnumToString.parse(ConsultStatus.InReview),
        ]),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  Stream<List<Consult>> getConsultsForProvider(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query.where('provider_id', isEqualTo: uid),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  Stream<List<Consult>> getActiveConsultsForPatient(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) =>
            query.where('patient_id', isEqualTo: uid).where("state", whereIn: [
          EnumToString.parse(ConsultStatus.PendingPayment),
          EnumToString.parse(ConsultStatus.PendingReview),
          EnumToString.parse(ConsultStatus.InReview),
        ]),
        sort: (lhs, rhs) => rhs.date.compareTo(lhs.date),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  Future<ConsultReviewOptions> consultReviewOptions({String symptomName}) =>
      _service
          .documentStream(
            path: FirestorePath.consultReviewOptions(symptomName),
            builder: (data, documentId) =>
                ConsultReviewOptions.fromMap(data, documentId),
          )
          .first;

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

  Future<ScreeningQuestions> consultQuestionnaire({String consultId}) =>
      _service
          .documentStream(
            path: FirestorePath.questionnaire(consultId),
            builder: (data, documentId) =>
                ScreeningQuestions.fromMap(data, documentId),
          )
          .first;

  Stream<List<Consult>> getTotalConsultsForPatient(String uid) =>
      _service.collectionStream(
        path: FirestorePath.consults(),
        queryBuilder: (query) => query.where('patient_id', isEqualTo: uid),
        sort: (lhs, rhs) => rhs.date.compareTo(lhs.date),
        builder: (data, documentId) => Consult.fromMap(data, documentId),
      );

  Future<void> saveVisitReview(
      {String consultId, VisitReviewData visitReviewData}) async {
    await _service.setData(
      path: FirestorePath.visitReview(consultId),
      data: visitReviewData.toMap(),
      merge: true,
    );
  }

  @override
  Future getConsultDetail(DetailedHistoryState detailedHistoryState) async {
    if (consultSnapshot == null &&
        consultSnapshot.documentID != null &&
        consultSnapshot.documentID != consultSnapshot.documentID) {
      consultRef = Firestore.instance
          .collection('consults')
          .document(consultSnapshot.documentID);
      await consultRef.get().then((datasnapshot) async {
        if (datasnapshot.data != null) {
          consultSnapshot = datasnapshot;
          consultSnapshot.data['details'] = [
            consultSnapshot['screening_questions'],
            consultSnapshot['media']
          ];
          if (consultSnapshot['state'] == 'done') {
            detailedHistoryState.updateWith(isDone: true);
          } else {
            detailedHistoryState.updateWith(isDone: false);
          }
        }
        return consultSnapshot;
      }).catchError((e) => print(e));
    }
  }

  @override
  Stream<QuerySnapshot> getConsultPrescriptions(consultId) {
    return Firestore.instance
        .collection('consults')
        .document(consultId)
        .collection('prescriptions')
        .snapshots();
  }

  Future<DocumentSnapshot> getMedicalHistoryQuestions() {
    return Firestore.instance.document('services/general_questions').get();
  }

  Future getDiagnosisQuestions(String type) async {
    consultRef = Firestore.instance.document('services/dermatology/symptoms/' +
        type.toLowerCase() +
        '/diagnosis/questions');
    await consultRef.get().then((datasnapshot) async {
      newConsult = ConsultData(
          historyQuestions: datasnapshot.data['diagnosis questions']);
      return datasnapshot.data['diagnosis questions'];
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> setDiagnosisQuestions(questions) async {
    //if not over the counter write prescription
    List<String> medicationName = questions[2]['answer'][0].split(';');
    String medName = medicationName[0].split(' ')[0];
    List<String> medDoseList = medicationName[0].split(' ').toList();
    String units = '';
    if (medicationName[0].contains('foam')) {
      units = 'foam';
    }
    if (medicationName[0].contains('pill')) {
      units = 'pill';
    }
    if (medicationName[0].contains('ointment')) {
      units = 'ointment';
    }
    medDoseList.removeAt(0);
    final DocumentReference documentReference = Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID)
        .collection('prescriptions')
        .document();
    final Future<DocumentSnapshot> priceDocument = Firestore.instance
        .collection('services/dermatology/symptoms/' +
            consultSnapshot.data['type'].toLowerCase() +
            '/treatment')
        .document(medName)
        .get();
    await priceDocument.then((onValue) async {
      Map<String, dynamic> data = <String, dynamic>{
        "date": DateTime.now(),
        "pay_date": null,
        "shipping_address": null,
        "medication_name": medName,
        "quantity": medicationName[1].split(':')[1],
        "units": units,
        "refills": int.parse(medicationName[2].split(':')[1]),
        "dose": medDoseList[0],
        "price": onValue.data["price"],
        "instructions": medicationName[3].split(':')[1],
        "state": "prescription waiting"
      };
      await documentReference.setData(data).whenComplete(() {
        print("Prescription Updated");
      }).catchError((e) => print(e));
    });

    //write the rest of the diagnosis questions
    return Firestore.instance
        .collection("consults")
        .document(consultSnapshot.documentID)
        .updateData({
      'diagnosis': questions[0]['answer'][0],
      'exam': questions[1]['answer'],
      'education': questions[3]['answer'],
      'doctor_notes': questions[4]['answer'],
      'follow_up': questions[5]['answer'],
    });
  }

  saveConsultChatImage(User _medicallUser, File chatMedia) async {
    final StorageReference storageRef = FirebaseStorage.instance.ref().child(
        "consults/" +
            _medicallUser.uid +
            '/' +
            consultSnapshot.documentID +
            '/' +
            path.basename(chatMedia.path));

    StorageUploadTask uploadTask = storageRef.putFile(
      chatMedia,
      StorageMetadata(
        contentType: 'image/jpg',
      ),
    );
    StorageTaskSnapshot download = await uploadTask.onComplete;

    consultChatImageUrl = await download.ref.getDownloadURL();
    ChatMessage message = ChatMessage(
        text: "",
        user: ChatUser(
            avatar: _medicallUser.profilePic,
            uid: _medicallUser.uid,
            name: _medicallUser.fullName),
        image: consultChatImageUrl);

    createNewConsultChatMsg(message);
  }

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

  Future<void> setPrescriptionPayment(state, shipTo, shippingAddress) {
    return Firestore.instance
        .collection("consults")
        .document(consultSnapshot.documentID)
        .updateData({
      'state': 'prescription paid',
      'pay_date': DateTime.now(),
      'shipping_option': shipTo,
      'shipping_address': shippingAddress,
    });
  }

  Future saveImages(assets, consultId, listaU8L, {@required String uid}) async {
    var allMediaList = [];
    var allFileNames = [];
    for (var i = 0; i < assets.length; i++) {
      if (!allFileNames.contains(assets[i].name)) {
        allFileNames.add(assets[i].name);
      } else {
        allFileNames.add(assets[i].name.split('.')[0] +
            '_' +
            i.toString() +
            '.' +
            assets[i].name.split('.')[1]);
      }
    }
    for (var i = 0; i < listaU8L.length; i++) {
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child("consults/" + uid + '/' + consultId + "/" + allFileNames[i]);
      StorageUploadTask uploadTask = ref.putData(listaU8L[i]);
      allMediaList
          .add(await (await uploadTask.onComplete).ref.getDownloadURL());
    }
    return allMediaList;
  }

  Stream<QuerySnapshot> getAllProviders() {
    return Firestore.instance
        .collection('users')
        .where("type", isEqualTo: "provider")
        .snapshots();
  }

  Future<void> addConsult(context, newConsult, extImageProvider,
      {@required User medicallUser}) async {
    var ref = Firestore.instance.collection('consults').document();

    var imagesList = await saveImages(
        extImageProvider.assetList, ref.documentID, extImageProvider.listaU8L,
        uid: medicallUser.uid);
    Map<String, dynamic> data = <String, dynamic>{
      "screening_questions": newConsult.screeningQuestions,
      "type": newConsult.consultType,
      "state": "new",
      "date": DateTime.now(),
      "doctor_notes": "",
      "provider": newConsult.provider,
      "providerTitles": newConsult.providerTitles,
      "patient": medicallUser.fullName,
      "provider_profile": newConsult.providerProfilePic,
      "patient_profile": medicallUser.profilePic,
      "consult_price": newConsult.price,
      "provider_id": newConsult.providerId,
      "patient_id": medicallUser.uid,
      "media": newConsult.media.length > 0 ? imagesList : "",
    };
    return ref.setData(data).then((val) {
      var chatRef =
          Firestore.instance.collection('chat').document(ref.documentID);
      Map<String, dynamic> chatData = <String, dynamic>{
        "provider": newConsult.provider,
        "providerTitles": newConsult.providerTitles,
        "patient": medicallUser.fullName,
        "provider_profile": newConsult.providerProfilePic,
        "patient_profile": medicallUser.profilePic,
        "provider_id": newConsult.providerId,
        "patient_id": medicallUser.uid,
      };

      chatRef.setData(chatData);
      var msgDocument = chatRef
          .collection('messages')
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      var chatContent = ChatMessage(
              text: "Hello, please take a look at my concerns, thank you.",
              user: ChatUser(
                  name: medicallUser.fullName,
                  uid: medicallUser.uid,
                  avatar: medicallUser.profilePic))
          .toJson();
      msgDocument.setData(chatContent);
    });
  }

  Stream getConsultChat() {
    return Firestore.instance
        .collection('chat')
        .document(consultSnapshot.documentID)
        .collection('messages')
        .snapshots();
  }

  createNewConsultChatMsg(ChatMessage message) {
    var documentReference = Firestore.instance
        .collection('chat')
        .document(consultSnapshot.documentID)
        .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
      );
    });
  }

  updatePatientUnreadChat(bool reset) async {
    consultRef = Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID);
    await consultRef.get().then((datasnapshot) async {
      if (datasnapshot.data != null) {
        consultSnapshot = datasnapshot;
      }
      int unread = consultSnapshot.data.containsKey('patient_unread_chat')
          ? consultSnapshot.data['patient_unread_chat']
          : 1;
      unread++;
      if (reset) {
        unread = 0;
      }
      consultRef.updateData({'patient_unread_chat': unread}).whenComplete(() {
        print("patient unread updated " + unread.toString());
      }).catchError((e) => print(e));
      return consultSnapshot;
    }).catchError((e) => print(e));
  }

  updateProviderUnreadChat(bool reset) async {
    consultRef = Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID);
    await consultRef.get().then((datasnapshot) async {
      if (datasnapshot.data != null) {
        consultSnapshot = datasnapshot;
      }
      int unread = consultSnapshot.data.containsKey('provider_unread_chat')
          ? consultSnapshot.data['provider_unread_chat']
          : 1;
      print(unread);
      unread++;
      print(unread);
      if (reset) {
        unread = 0;
      }
      consultRef.updateData({'provider_unread_chat': unread}).whenComplete(() {
        print("provider unread updated " + unread.toString());
      }).catchError((e) => print(e));
      return consultSnapshot;
    }).catchError((e) => print(e));
  }

  Stream getAllUsers() {
    return Firestore.instance.collection('users').snapshots();
  }

  Future<void> updatePrescription(consultFormKey) async {
    final DocumentReference documentReference = Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID)
        .collection('prescriptions')
        .document();
    Map<String, dynamic> data = <String, dynamic>{
      "date": DateTime.now(),
      "pay_date": null,
      "shipping_address": null,
      "medication_name":
          consultFormKey.currentState.fields['medName'].currentState.value,
      "quantity":
          consultFormKey.currentState.fields['quantity'].currentState.value,
      "units": consultFormKey.currentState.fields['units'].currentState.value,
      "refills":
          consultFormKey.currentState.fields['refills'].currentState.value,
      "dose": consultFormKey.currentState.fields['dose'].currentState.value,
      "frequency":
          consultFormKey.currentState.fields['frequency'].currentState.value,
      "instructions":
          consultFormKey.currentState.fields['instructions'].currentState.value,
      "state": "prescription waiting"
    };
    await documentReference.setData(data).whenComplete(() {
      consultSnapshot.data['medication_name'] =
          consultFormKey.currentState.fields['medName'].currentState.value;
      consultSnapshot.data['quantity'] =
          consultFormKey.currentState.fields['quantity'].currentState.value;
      consultSnapshot.data['units'] =
          consultFormKey.currentState.fields['units'].currentState.value;
      consultSnapshot.data['refills'] =
          consultFormKey.currentState.fields['refills'].currentState.value;
      consultSnapshot.data['frequency'] =
          consultFormKey.currentState.fields['frequency'].currentState.value;
      consultSnapshot.data['instructions'] =
          consultFormKey.currentState.fields['instructions'].currentState.value;
      consultSnapshot.data['state'] = "prescription waiting";

      print("Prescription Updated");
    }).catchError((e) => print(e));
  }

  updateConsultStatus(Choice choice, String uid) {
    consultRef = Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID);
    if (consultSnapshot.documentID == consultSnapshot.documentID &&
        consultSnapshot.data['provider_id'] == uid) {
      if (choice.title == 'Done') {
        consultStateData = {'state': 'done'};
      } else {
        consultStateData = {'state': 'in progress'};
      }
      consultRef.updateData(consultStateData).whenComplete(() {
        print('Consult Updated');
      }).catchError((e) => print(e));
    }
  }

  @override
  Future<void> getPatientDetail(User medicallUser) async {
    final DocumentReference documentReference = Firestore.instance
        .collection('users')
        .document(consultSnapshot.data['patient_id']);
    await documentReference.get().then((datasnapshot) async {
      if (datasnapshot.data != null) {
        patientDetail = PatientUser();
        patientDetail.address = datasnapshot.data['address'];
        patientDetail.fullName = datasnapshot.data['name'];
        patientDetail.dob = datasnapshot.data['dob'];
        patientDetail.gender = datasnapshot.data['gender'];
        patientDetail.phoneNumber = datasnapshot.data['phone'];
        _getUserPaymentCard(medicallUser);
      }
    }).catchError((e) => print(e));
  }

  Future _getUserPaymentCard(User medicallUser) async {
    List<PaymentMethod> sources = (await getUserCardSources(medicallUser.uid));
    hasPayment = sources.length > 0;
  }

  Stream getUserHistoryStream(medicallUser) {
    return Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID)
        .snapshots();
  }

  Future<void> addUserMedicalHistory(User medicallUser) async {
    if (medicallUser.uid.length > 0) {
      final DocumentReference ref = Firestore.instance
          .collection('medical_history')
          .document(medicallUser.uid);
      Map<String, dynamic> data = <String, dynamic>{
        "medical_history_questions": newConsult.historyQuestions,
      };
      ref.setData(data).whenComplete(() {
        print("Consult Added");
      }).catchError((e) => print(e));
    }
  }

  Future<void> getUserMedicalHistory(User medicallUser) async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(medicallUser.uid)
          .get();
    }
  }

  Future<dynamic> getSymptoms(User medicallUser) async {
    // userMedicalRecord = await Firestore.instance
    //       .collection('medical_history')
    //       .document(medicallUser.uid)
    //       .get();
    return Firestore.instance
        .collection('services')
        .document('dermatology')
        .collection('symptoms')
        .getDocuments();
  }

  Future<QuerySnapshot> getUserSources({@required String uid}) {
    return Firestore.instance
        .collection('cards')
        .document(uid)
        .collection('sources')
        .getDocuments();
  }

  Future<void> getPatientMedicalHistory(User medicallUser) async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(consultSnapshot.data['patient_id'])
          .get();
    }
  }

  Future<void> getConsultQuestions() async {
    consultQuestions = await Firestore.instance
        .document('services/dermatology/symptoms/' +
            newConsult.consultType.toLowerCase())
        .get();
  }

  sendChatMsg(content, {@required String uid}) {
    final DocumentReference documentReference = Firestore.instance
        .collection('consults')
        .document(consultSnapshot.documentID);
    Map<String, dynamic> data = {
      'chat': FieldValue.arrayUnion([
        {
          'user_id': uid,
          'date': DateTime.now(),
          'txt': content,
        }
      ])
    };
    documentReference.snapshots().forEach((snap) {
      if (snap.data['provider_id'] == uid && snap.data['state'] == 'new') {
        Map<String, dynamic> consultStateData = {'state': 'in progress'};
        documentReference.updateData(consultStateData).whenComplete(() {
          print("Msg Sent");
        }).catchError((e) => print(e));
      }
    });
    documentReference.updateData(data).whenComplete(() {
      print("Msg Sent");
    }).catchError((e) => print(e));
  }
}
