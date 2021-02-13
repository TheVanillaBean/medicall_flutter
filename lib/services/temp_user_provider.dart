import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/shared/login/apple_sign_in_model.dart';
import 'package:Medicall/screens/shared/login/google_auth_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TempUserProvider {
  USER_TYPE _userType;
  MedicallUser _user;
  String password;
  GoogleAuthModel googleAuthModel;
  AppleSignInModel appleSignInModel;
  List<Asset> images;
  Consult consult;
  Symptom symptom;
  String insurance;

  MedicallUser get user => _userType == USER_TYPE.PATIENT
      ? _user as PatientUser
      : _user as ProviderUser;
  USER_TYPE get userType => _userType;

  void setUser({@required USER_TYPE userType, MedicallUser user}) {
    this._userType = userType;
    if (_userType == USER_TYPE.PATIENT) {
      this._user = user == null ? PatientUser() : user as PatientUser;
    } else {
      this._user = user == null ? ProviderUser() : user as ProviderUser;
    }
    this._user.type = userType;
  }
}
