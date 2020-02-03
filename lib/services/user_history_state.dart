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

  getUserHistorySnapshots(
      MedicallUser medicallUser, String searchQuery, int sortBy, context) {
    if (medicallUser.uid.length > 0) {
      return sortBy == 1
          ? Firestore.instance
              .collection('consults')
              .where(
                  medicallUser.type == 'provider'
                      ? 'provider_id'
                      : 'patient_id',
                  isEqualTo: medicallUser.uid)
              .orderBy('date', descending: true)
              .snapshots()
          : sortBy == 2
              ? Firestore.instance
                  .collection('consults')
                  .where(
                      medicallUser.type == 'provider'
                          ? 'provider_id'
                          : 'patient_id',
                      isEqualTo: medicallUser.uid)
                  .orderBy(
                      medicallUser.type == 'provider' ? 'patient' : 'provider',
                      descending: false)
                  .snapshots()
              : sortBy == 3
                  ? Firestore.instance
                      .collection('consults')
                      .where(
                          medicallUser.type == 'provider'
                              ? 'provider_id'
                              : 'patient_id',
                          isEqualTo: medicallUser.uid)
                      .where('state', isEqualTo: 'new')
                      .orderBy('date', descending: true)
                      .snapshots()
                  : sortBy == 4
                      ? Firestore.instance
                          .collection('consults')
                          .where(
                              medicallUser.type == 'provider'
                                  ? 'provider_id'
                                  : 'patient_id',
                              isEqualTo: medicallUser.uid)
                          .where('state', isEqualTo: 'in progress')
                          .orderBy('date', descending: true)
                          .snapshots()
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
                              .snapshots()
                          : Firestore.instance
                              .collection('consults')
                              .where(
                                  medicallUser.type == 'provider'
                                      ? 'provider_id'
                                      : 'patient_id',
                                  isEqualTo: medicallUser.uid)
                              .where('state', isEqualTo: 'done')
                              .orderBy('date', descending: true)
                              .snapshots();
    }
  }
}
