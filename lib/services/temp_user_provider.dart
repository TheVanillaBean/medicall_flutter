import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TempUserProvider {
  USER_TYPE _userType;
  User _user;
  String password;
  GoogleAuthModel googleAuthModel;
  AppleSignInModel appleSignInModel;
  List<Asset> images;
  Consult consult;
  Symptom symptom;
  List<dynamic> malpracticeQuestions;

  User get user => _userType == USER_TYPE.PATIENT
      ? _user as PatientUser
      : _user as ProviderUser;
  USER_TYPE get userType => _userType;

  void setUser({@required USER_TYPE userType, User user}) {
    this._userType = userType;
    if (_userType == USER_TYPE.PATIENT) {
      this._user = user == null ? PatientUser() : user as PatientUser;
    } else {
      this._user = user == null ? ProviderUser() : user as ProviderUser;
    }
    this._user.type = userType;
  }

  //Below functions will be phased out once database.dart is refactored

  void getMalpracticeQuestions() {
    final DocumentReference ref =
        Firestore.instance.document('services/malpractice_questions');
    ref.get().then((val) {
      this.malpracticeQuestions = val.data['malpractice_questions'];
    });
  }

  Future<void> addProviderMalPractice() async {
    if (user.uid.length > 0) {
      final DocumentReference ref =
          Firestore.instance.collection('malpractice').document(user.uid);
      Map<String, dynamic> data = <String, dynamic>{
        "malpractice_questions": this.malpracticeQuestions,
      };
      ref.setData(data).whenComplete(() {
        print("Questions Added");
      }).catchError((e) => print(e));
    }
  }
}
