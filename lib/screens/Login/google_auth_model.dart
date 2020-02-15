import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class GoogleAuthModel {
  final AuthCredential credential;
  final String displayName;
  final String email;
  final List<String> providers;

  GoogleAuthModel({
    @required this.displayName,
    @required this.credential,
    @required this.email,
    @required this.providers,
  });

  String get firstName {
    return displayName != null ? displayName.split(' ')[0] : "";
  }

  String get lastName {
    return displayName != null ? displayName.split(' ')[1] : "";
  }
}
