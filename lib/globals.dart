library medicall.globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

GoogleSignInAccount currentUser;
FirebaseUser currentFirebaseUser;

class ConsultData {
  String consultType;
  List<dynamic> screeningQuestions;
  List<dynamic> stringListQuestions;
  String provider;
  String providerId;
  List<dynamic> historyQuestions;
  List<Asset> media;

  ConsultData({
    this.consultType,
    this.screeningQuestions,
    this.stringListQuestions,
    this.provider,
    this.providerId,
    this.historyQuestions,
    this.media,
  });
}
