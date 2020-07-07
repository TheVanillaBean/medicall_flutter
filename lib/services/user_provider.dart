import 'package:Medicall/models/user_model_base.dart';
import 'package:flutter/material.dart';

class UserProvider {
  User _user;

  User get user {
    return _user;
  }

  set user(user) {
    _user = user;
  }

  UserProvider({@required User user}) : assert(user != null) {
    this.user = user;
  }
}
