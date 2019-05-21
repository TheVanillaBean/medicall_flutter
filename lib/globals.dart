library medicall.globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

GoogleSignInAccount currentUser;
FirebaseUser currentFirebaseUser;

class ConsultData {
  String consultType;
  List<String> screeningQuestions;
  String provider;
  List<String> historyQuestions;
  List<Asset> media;

  ConsultData({
    this.consultType,
    this.screeningQuestions,
    this.provider,
    this.historyQuestions,
    this.media,
  });
}
