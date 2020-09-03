import 'package:Medicall/models/user_model_base.dart';
import 'package:flutter/material.dart';

class UserProvider {
  MedicallUser _user;

  MedicallUser get user {
    return _user;
  }

  set user(user) {
    _user = user;
  }

  UserProvider({@required MedicallUser user}) : assert(user != null) {
    this.user = user;
  }
}
