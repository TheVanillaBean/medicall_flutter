import 'package:Medicall/models/medicall_user_model.dart';
import 'package:flutter/material.dart';

class UserProvider {
  MedicallUser _medicallUser;

  MedicallUser get medicallUser {
    return _medicallUser;
  }

  set medicallUser(user) {
    _medicallUser = user;
  }

  UserProvider({@required MedicallUser medicallUser})
      : assert(medicallUser != null) {
    this.medicallUser = medicallUser;
  }
}
