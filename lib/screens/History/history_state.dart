import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryState with ChangeNotifier {
  User medicallUser;
  AsyncSnapshot historySnapshot;
  ExtendedImageProvider extendedImageProvider;
  Database db;
  HistoryState(
      {@required this.medicallUser,
      @required this.extendedImageProvider,
      @required this.db});
  List<DocumentSnapshot> userHistory = [];

  void setUserHistory(List<DocumentSnapshot> snapshot) {
    userHistory = snapshot;
    notifyListeners();
  }

  int sortBy = 1;

  getUserHistorySnapshot(User medicallUser, String searchQuery, int sortBy) {
    if (medicallUser.uid.length > 0) {
      if (sortBy == 1) {
        return Firestore.instance
            .collection('consults')
            .where(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? 'provider_id'
                    : 'patient_id',
                isEqualTo: medicallUser.uid)
            .orderBy('date', descending: true)
            .snapshots();
      }
      if (sortBy == 2) {
        return Firestore.instance
            .collection('consults')
            .where(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? 'provider_id'
                    : 'patient_id',
                isEqualTo: medicallUser.uid)
            .orderBy(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? USER_TYPE.PATIENT
                    : 'provider',
                descending: false)
            .snapshots();
      }
      if (sortBy == 3) {
        return Firestore.instance
            .collection('consults')
            .where(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? 'provider_id'
                    : 'patient_id',
                isEqualTo: medicallUser.uid)
            .where('state', isEqualTo: 'new')
            .orderBy('date', descending: true)
            .snapshots();
      }
      if (sortBy == 4) {
        return Firestore.instance
            .collection('consults')
            .where(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? 'provider_id'
                    : 'patient_id',
                isEqualTo: medicallUser.uid)
            .where('state', isEqualTo: 'in progress')
            .orderBy('date', descending: true)
            .snapshots();
      }
      if (sortBy == 5) {
        return Firestore.instance
            .collection('consults')
            .where(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? 'provider_id'
                    : 'patient_id',
                isEqualTo: medicallUser.uid)
            .where('state', isEqualTo: 'prescription waiting')
            .orderBy('date', descending: true)
            .snapshots();
      }
      if (sortBy == 6) {
        return Firestore.instance
            .collection('consults')
            .where(
                medicallUser.type == USER_TYPE.PROVIDER
                    ? 'provider_id'
                    : 'patient_id',
                isEqualTo: medicallUser.uid)
            .where('state', isEqualTo: 'done')
            .orderBy('date', descending: true)
            .snapshots();
      }
    }
  }

  sortUserHistory(snapshot) {
    var sortedUserHistory = [];
    if (snapshot.data.documents != null) {
      for (var i = 0; i < snapshot.data.documents.length; i++) {
        // if (!sortedUserHistory.contains(snapshot.data.documents[i])) {
        //   if (searchInput.length > 0) {
        //     if (snapshot.data.documents[i].data[USER_TYPE.PATIENT]
        //             .toLowerCase()
        //             .contains(
        //               searchInput.toLowerCase(),
        //             ) ||
        //         snapshot.data.documents[i].data['provider']
        //             .toLowerCase()
        //             .contains(
        //               searchInput.toLowerCase(),
        //             ) ||
        //         snapshot.data.documents[i].data['state'].toLowerCase().contains(
        //               searchInput.toLowerCase(),
        //             ) ||
        //         snapshot.data.documents[i].data['type'].toLowerCase().contains(
        //               searchInput.toLowerCase(),
        //             )) {
        //       sortedUserHistory.add(snapshot.data.documents[i]);
        //     }
        //   } else {
        //     sortedUserHistory.add(snapshot.data.documents[i]);
        //   }
        // }
      }
    }
    return sortedUserHistory;
  }
}
