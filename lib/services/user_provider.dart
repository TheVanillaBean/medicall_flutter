import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/firestore_service.dart';
import 'package:flutter/material.dart';

import 'firestore_path.dart';

class UserProvider {
  // ignore: close_sinks
  MedicallUser _user;

  final _service = FirestoreService.instance;

  MedicallUser get user {
    return _user;
  }

  set user(user) {
    _user = user;
  }

  UserProvider({@required MedicallUser user}) : assert(user != null) {
    this.user = user;

    _service
        .documentStream(
      path: FirestorePath.user(this._user.uid),
      builder: (data, documentId) => MedicallUser.fromMap(
          userType: this.user.type, data: data, uid: documentId),
    )
        .listen((updatedUser) {
      this.user = updatedUser;
    });
  }
}
