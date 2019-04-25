library medicall.globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:json_annotation/json_annotation.dart';

GoogleSignInAccount currentUser;
FirebaseUser currentFirebaseUser;
MedicallUser medicallUser;

@JsonSerializable(nullable: false)
class Person {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  Person({this.firstName, this.lastName, this.dateOfBirth});
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

Person _$PersonFromJson(Map<String, dynamic> json) {
  return Person(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String));
}

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String()
    };

class MedicallUser {
  String displayName;
  String firstName;
  String lastName;
  String dob;
  String phoneNumber;
  String email;
  bool terms;
  bool policy;

  MedicallUser({
    this.displayName,
    this.firstName,
    this.lastName,
    this.dob,
    this.phoneNumber,
    this.email,
    this.terms,
    this.policy,
  });

  MedicallUser.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        dob = json['dob'],
        phoneNumber = json['phoneNumber'],
        email = json['email'],
        terms = json['terms'],
        policy = json['policy'];

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob,
        'phoneNumber': phoneNumber,
        'email': email,
        'terms': terms,
        'policy': policy,
      };
}
