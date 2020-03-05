import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AppleSignInModel {
  final AuthCredential credential;
  final String displayName;
  final String email;
  final List<String> providers;

  AppleSignInModel({
    @required this.displayName,
    @required this.credential,
    @required this.email,
    @required this.providers,
  });
}
