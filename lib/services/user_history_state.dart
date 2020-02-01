import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserHistoryState with ChangeNotifier {
  UserHistoryState();

  List<DocumentSnapshot> userHistory = [];

  void setUserHistory(List<DocumentSnapshot> index) {
    userHistory = index;
    notifyListeners();
  }

  Future<List<DocumentSnapshot>> getUserHistory(MedicallUser medicallUser,
      String searchQuery, int sortBy, context) async {
    if (medicallUser.uid.length > 0) {
      final Future<QuerySnapshot> documentReference = sortBy == 1
          ? Firestore.instance
              .collection('consults')
              .where(medicallUser.type == 'provider' ? 'provider_id' : 'patient_id',
                  isEqualTo: medicallUser.uid)
              .orderBy('date', descending: true)
              .getDocuments()
          : sortBy == 2
              ? Firestore.instance
                  .collection('consults')
                  .where(medicallUser.type == 'provider' ? 'provider_id' : 'patient_id',
                      isEqualTo: medicallUser.uid)
                  .orderBy(medicallUser.type == 'provider' ? 'patient' : 'provider',
                      descending: false)
                  .getDocuments()
              : sortBy == 3
                  ? Firestore.instance
                      .collection('consults')
                      .where(medicallUser.type == 'provider' ? 'provider_id' : 'patient_id',
                          isEqualTo: medicallUser.uid)
                      .where('state', isEqualTo: 'new')
                      .orderBy('date', descending: true)
                      .getDocuments()
                  : sortBy == 4
                      ? Firestore.instance
                          .collection('consults')
                          .where(medicallUser.type == 'provider' ? 'provider_id' : 'patient_id',
                              isEqualTo: medicallUser.uid)
                          .where('state', isEqualTo: 'in progress')
                          .orderBy('date', descending: true)
                          .getDocuments()
                      : sortBy == 5
                          ? Firestore.instance
                              .collection('consults')
                              .where(
                                  medicallUser.type == 'provider'
                                      ? 'provider_id'
                                      : 'patient_id',
                                  isEqualTo: medicallUser.uid)
                              .where('state', isEqualTo: 'prescription waiting')
                              .orderBy('date', descending: true)
                              .getDocuments()
                          : Firestore.instance
                              .collection('consults')
                              .where(
                                  medicallUser.type == 'provider'
                                      ? 'provider_id'
                                      : 'patient_id',
                                  isEqualTo: medicallUser.uid)
                              .where('state', isEqualTo: 'done')
                              .orderBy('date', descending: true)
                              .getDocuments();
      await documentReference.then((datasnapshot) {
        if (datasnapshot.documents != null) {
          userHistory = [];
          for (var i = 0; i < datasnapshot.documents.length; i++) {
            if (!userHistory.contains(datasnapshot.documents[i])) {
              if (searchQuery.length > 0) {
                if (datasnapshot.documents[i].data['provider']
                        .toLowerCase()
                        .contains(
                          searchQuery.toLowerCase(),
                        ) ||
                    datasnapshot.documents[i].data['state']
                        .toLowerCase()
                        .contains(
                          searchQuery.toLowerCase(),
                        ) ||
                    datasnapshot.documents[i].data['type']
                        .toLowerCase()
                        .contains(
                          searchQuery.toLowerCase(),
                        )) {
                  userHistory.add(datasnapshot.documents[i]);
                }
              } else {
                userHistory.add(datasnapshot.documents[i]);
              }
            }
          }
        }
      }).catchError((e) => print(e));
    }
    return userHistory;
  }
}
