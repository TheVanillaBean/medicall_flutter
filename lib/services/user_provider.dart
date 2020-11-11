import 'package:Medicall/models/user/user_model_base.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  MedicallUser _user;

  MedicallUser get user {
    return _user;
  }

  set user(user) {
    _user = user;
  }

  void updateUser(MedicallUser user) {
    _user = user;
    notifyListeners();
  }

  UserProvider({@required MedicallUser user}) : assert(user != null) {
    this.user = user;
  }
}
