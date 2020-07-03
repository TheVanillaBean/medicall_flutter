import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TempUserProvider {
  User _medicallUser;
  List<dynamic> malpracticeQuestions;
  List<Asset> _images;
  String _password;
  GoogleAuthModel _googleAuthModel;
  AppleSignInModel _appleSignInModel;
  Consult consult;
  Symptom symptom;

  User get medicallUser => _medicallUser;

  List<Asset> get images => _images;

  String get password => _password;

  GoogleAuthModel get googleAuthModel => _googleAuthModel;

  AppleSignInModel get appleSignInModel => _appleSignInModel;

  getMalpracticeQuestions() {
    final DocumentReference ref =
        Firestore.instance.document('services/malpractice_questions');
    ref.get().then((val) {
      this.malpracticeQuestions = val.data['malpractice_questions'];
    });
  }

  Future<void> addProviderMalPractice() async {
    if (medicallUser.uid.length > 0) {
      final DocumentReference ref = Firestore.instance
          .collection('malpractice')
          .document(medicallUser.uid);
      Map<String, dynamic> data = <String, dynamic>{
        "malpractice_questions": this.malpracticeQuestions,
      };
      ref.setData(data).whenComplete(() {
        print("Questions Added");
      }).catchError((e) => print(e));
    }
  }
}
