//import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/reg_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class Database {
  Future<void> getConsultDetail();
  Future<void> getPatientDetail(MedicallUser medicallUser);
  Future<void> getUserHistory(MedicallUser medicallUser);
  Future<void> setPrescriptionPayment(state, shipTo, shippingAddress);
  Future<void> updatePrescription(consultFormKey);
  Future<void> addUser(user, context);
  addUserMedicalHistory(MedicallUser medicallUser);
  getUserMedicalHistory(MedicallUser medicallUser);
  getPatientMedicalHistory(MedicallUser medicallUser);
  getConsultQuestions(MedicallUser medicallUser);
  Stream<QuerySnapshot> getAllProviders();
  Future<DocumentSnapshot> getMedicalHistoryQuestions();
  Stream getAllUsers();
  Stream getUserHistoryStream();
  Future<QuerySnapshot> getUserSources();
  Future<void> addConsult(context, newConsult, extImageProvider);
  updateConsultStatus(Choice choice, MedicallUser medicallUser);
  sendChatMsg(
    content,
  );
  Stream<QuerySnapshot> getUserCardSources();

  DocumentSnapshot consultSnapshot;
  DocumentReference consultRef;
  String currConsultId;
  Map<String, dynamic> consultStateData;
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
  DocumentReference consultRef;
  @override
  String currConsultId;
  @override
  Map<String, dynamic> consultStateData;
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
    if (consultSnapshot == null && currConsultId != null ||
        currConsultId != consultSnapshot.documentID) {
      consultRef =
          Firestore.instance.collection('consults').document(currConsultId);
      await consultRef.get().then((datasnapshot) async {
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

  Future<DocumentSnapshot> getMedicalHistoryQuestions() {
    return Firestore.instance.document('services/general_questions').get();
  }

  Stream<QuerySnapshot> getUserCardSources() {
    return Firestore.instance
        .collection('cards')
        .document(medicallUser.uid)
        .collection('sources')
        .snapshots();
  }

  Future<void> addUser(user, context) async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + user.uid);
    medicallUser.phoneNumber = user.phoneNumber;
    Map<String, dynamic> data = <String, dynamic>{
      "name": medicallUser.displayName,
      "first_name": medicallUser.firstName,
      "last_name": medicallUser.lastName,
      "email": user.email,
      "gender": medicallUser.gender,
      "type": medicallUser.type,
      "address": medicallUser.address,
      "terms": medicallUser.terms,
      "policy": medicallUser.policy,
      "consent": medicallUser.consent,
      "dob": medicallUser.dob,
      "phone": user.phoneNumber,
      "profile_pic": medicallUser.profilePic,
      "gov_id": medicallUser.govId,
      "dev_tokens": medicallUser.devTokens,
    };
    if (medicallUser.type == 'provider') {
      data['titles'] = medicallUser.titles;
      data['npi'] = medicallUser.npi;
      data['med_license'] = medicallUser.medLicense;
      data['state_issued'] = medicallUser.medLicenseState;
    }

    try {
      await documentReference.setData(data).then((onValue) {
        print('User added');
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> setPrescriptionPayment(state, shipTo, shippingAddress) {
    return Firestore.instance
        .collection("consults")
        .document(currConsultId)
        .updateData({
      'state': 'prescription paid',
      'pay_date': DateTime.now(),
      'shipping_option': shipTo,
      'shipping_address': shippingAddress,
    });
  }

  Future saveImages(assets, consultId, listaU8L) async {
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
      StorageReference ref = FirebaseStorage.instance.ref().child("consults/" +
          medicallUser.uid +
          '/' +
          consultId +
          "/" +
          allFileNames[i]);
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

  Future<void> addConsult(context, newConsult, extImageProvider) async {
    var ref = Firestore.instance.collection('consults').document();

    var imagesList = await saveImages(
        extImageProvider.assetList, ref.documentID, extImageProvider.listaU8L);
    Map<String, dynamic> data = <String, dynamic>{
      "screening_questions": newConsult.screeningQuestions,
      //"medical_history_questions": _db.newConsult.historyQuestions,
      "type": newConsult.consultType,
      "chat": [],
      "state": "new",
      "date": DateTime.now(),
      "medication_name": "",
      "provider": newConsult.provider,
      "providerTitles": newConsult.providerTitles,
      "patient": medicallUser.displayName,
      "provider_profile": newConsult.providerProfilePic,
      "patient_profile": medicallUser.profilePic,
      "consult_price": newConsult.price,
      "provider_id": newConsult.providerId,
      "patient_id": medicallUser.uid,
      "media": newConsult.media.length > 0 ? imagesList : "",
    };
    return ref.setData(data);
  }

  Stream getAllUsers() {
    return Firestore.instance.collection('users').snapshots();
  }

  Future<void> updatePrescription(consultFormKey) async {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(currConsultId);
    Map<String, dynamic> data = <String, dynamic>{
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
    await documentReference.updateData(data).whenComplete(() {
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

  updateConsultStatus(Choice choice, MedicallUser medicallUser) {
    if (consultSnapshot.documentID == currConsultId &&
        consultSnapshot.data['provider_id'] == medicallUser.uid) {
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
  Future<void> getPatientDetail(MedicallUser medicallUser) async {
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
        _getUserPaymentCard(medicallUser);
      }
    }).catchError((e) => print(e));
  }

  Future<void> _getUserPaymentCard(MedicallUser medicallUser) async {
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

  Future<void> getUserHistory(MedicallUser medicallUser) async {
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

  Stream getUserHistoryStream() {
    return Firestore.instance
        .collection('consults')
        .document(medicallUser.uid)
        .snapshots();
  }

  Future<void> addUserMedicalHistory(MedicallUser medicallUser) async {
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

  Future<void> getUserMedicalHistory(MedicallUser medicallUser) async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(medicallUser.uid)
          .get();
    }
  }

  Future<QuerySnapshot> getUserSources() {
    return Firestore.instance
        .collection('cards')
        .document(medicallUser.uid)
        .collection('sources')
        .getDocuments();
  }

  Future<void> getPatientMedicalHistory(MedicallUser medicallUser) async {
    if (medicallUser.uid.length > 0) {
      userMedicalRecord = await Firestore.instance
          .collection('medical_history')
          .document(consultSnapshot.data['patient_id'])
          .get();
    }
  }

  Future<void> getConsultQuestions(MedicallUser medicallUser) async {
    if (medicallUser.uid.length > 0) {
      consultQuestions = await Firestore.instance
          .document('services/dermatology/symptoms/' +
              newConsult.consultType.toLowerCase())
          .get();
    }
  }

  sendChatMsg(
    content,
  ) {
    final DocumentReference documentReference =
        Firestore.instance.collection('consults').document(currConsultId);
    Map<String, dynamic> data = {
      'chat': FieldValue.arrayUnion([
        {
          'user_id': medicallUser.uid,
          'date': DateTime.now(),
          'txt': content,
        }
      ])
    };
    documentReference.snapshots().forEach((snap) {
      if (snap.data['provider_id'] == medicallUser.uid &&
          snap.data['state'] == 'new') {
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
