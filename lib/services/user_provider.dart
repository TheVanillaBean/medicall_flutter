import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProvider with ChangeNotifier {
  MedicallUser _medicallUser;

  MedicallUser get medicallUser {
    return _medicallUser;
  }

  set medicallUser(user) {
    _medicallUser = user;
  }

  UserProvider({@required String uid}) : assert(uid != null) {
    _getMedicallUser(uid: uid);
  }

  Future<void> _getMedicallUser({@required String uid}) async {
    final DocumentReference documentReference =
        Firestore.instance.collection('users').document(uid);

    try {
      final snapshot = await documentReference.get();
      this._medicallUser = MedicallUser.from(uid, snapshot);
      medicallUser = MedicallUser.from(uid, snapshot);
      notifyListeners();
    } catch (e) {
      throw PlatformException(
        code: 'ERROR_RETRIEVE_USER',
        message: 'User could not be retrieved from database.',
      );
    }
  }
}
