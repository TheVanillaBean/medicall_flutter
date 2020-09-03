import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class GoogleAuthModel {
  final AuthCredential credential;
  final String fullName;
  final String email;
  final List<String> providers;

  GoogleAuthModel({
    @required this.fullName,
    @required this.credential,
    @required this.email,
    @required this.providers,
  });
}
