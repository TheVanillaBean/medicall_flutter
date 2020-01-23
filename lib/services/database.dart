//import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/reg_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {
  Future<void> getConsultDetail();
  Future<void> getPatientDetail();
  Future<void> getUserHistory();
  addUserMedicalHistory();
  getUserMedicalHistory();
  getPatientMedicalHistory();
  getConsultQuestions();

  DocumentSnapshot consultSnapshot;
  String currConsultId;
  bool isDone;
  MedicallUser patientDetail;
  bool hasPayment;
  var userMedicalRecord;
  List<DocumentSnapshot> userHistory;
  ConsultData newConsult;
  var consultQuestions;
  TempRegUser tempRegUser;
}

class FirestoreDatabase implements Database {
  String uid;
  @override
  DocumentSnapshot consultSnapshot;
  @override
  String currConsultId;
  @override
  bool isDone;
  @override
  MedicallUser patientDetail;
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
  TempRegUser tempRegUser;

  FirestoreDatabase();
  @override
  Future<void> getConsultDetail() async {
    if (consultSnapshot == null ||
        currConsultId != consultSnapshot.documentID) {
      final DocumentReference documentReference =
          Firestore.instance.collection('consults').document(currConsultId);
      await documentReference.get().then((datasnapshot) async {
        if (datasnapshot.data != null) {
          consultSnapshot = datasnapshot;
          consultSnapshot.data['details'] = [
            consultSnapshot['screening_questions'],
            consultSnapshot['media']
          ];
          if (consultSnapshot['state'] == 'done') {
            isDone = true;
          } else {
            isDone = false;
          }
        }
      }).catchError((e) => print(e));
    }
  }

  @override
  Future<void> getPatientDetail() async {
    final DocumentReference documentReference = Firestore.instance
        .collection('users')
        .document(consultSnapshot.data['patient_id']);
    await documentReference.get().then((datasnapshot) async {
      if (datasnapshot.data != null) {
        patientDetail = MedicallUser(
            address: datasnapshot.data['address'],
            displayName: datasnapshot.data['name'],
            dob: datasnapshot.data['dob'],
            gender: datasnapshot.data['gender'],
            phoneNumber: datasnapshot.data['phone']);
        _getUserPaymentCard();
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getUserPaymentCard() async {
    if (medicallUser.uid.length > 0) {
      final Future<QuerySnapshot> documentReference = Firestore.instance
          .collection('cards')
          .document(medicallUser.uid)
          .collection('sources')
          .getDocuments();
      await documentReference.then((datasnapshot) {
        if (datasnapshot.documents.length > 0) {
          hasPayment = true;
        }
      }).catchError((e) => print(e));
    }
  }

  Future<void> getUserHistory() async {
    if (medicallUser.uid.length > 0) {
      final Future<QuerySnapshot> documentReference = Firestore.instance
          .collection('consults')
          .where(medicallUser.type == 'provider' ? 'provider_id' : 'patient_id',
              isEqualTo: medicallUser.uid)
          .orderBy('date', descending: true)
          .getDocuments();
      await documentReference.then((datasnapshot) {
        if (datasnapshot.documents != null) {
          userHistory = [];
          for (var i = 0; i < datasnapshot.documents.length; i++) {
            if (!userHistory.contains(datasnapshot.documents[i])) {
              userHistory.add(datasnapshot.documents[i]);
            }
          }
        }
      }).catchError((e) => print(e));
    }
  }

  Future<void> addUserMedicalHistory() async {
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

  Future<void> getUserMedicalHistory() async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(medicallUser.uid)
          .get();
    }
  }

  Future<void> getPatientMedicalHistory() async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(consultSnapshot.data['patient_id'])
          .get();
    }
  }

  Future<void> getConsultQuestions() async {
    if (medicallUser.uid.length > 0) {
      consultQuestions = await Firestore.instance
          .document('services/dermatology/symptoms/' +
              newConsult.consultType.toLowerCase())
          .get();
    }
  }
}
