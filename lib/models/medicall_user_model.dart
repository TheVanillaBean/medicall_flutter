import 'package:cloud_firestore/cloud_firestore.dart';

MedicallUser medicallUser;

class MedicallUser {
  String uid;
  List<dynamic> devTokens;
  String type;
  String displayName;
  String firstName;
  String lastName;
  String dob;
  String gender;
  String phoneNumber;
  String email;
  String address;
  String titles;
  String medLicense;
  String medLicenseState;
  String npi;
  String profilePic;
  String govId;
  bool terms;
  bool policy;
  bool consent;
  bool hasMedicalHistory;

  MedicallUser({
    this.uid,
    this.devTokens,
    this.type,
    this.displayName,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
    this.phoneNumber,
    this.email,
    this.address,
    this.titles,
    this.npi,
    this.medLicense,
    this.medLicenseState,
    this.profilePic,
    this.govId,
    this.terms,
    this.policy,
    this.consent,
    this.hasMedicalHistory,
  });

  factory MedicallUser.from(DocumentSnapshot datasnapshot) {
    medicallUser.displayName = datasnapshot.data['name'];
    medicallUser.firstName = datasnapshot.data['first_name'];
    medicallUser.lastName = datasnapshot.data['last_name'];
    medicallUser.dob = datasnapshot.data['dob'];
    medicallUser.policy = datasnapshot.data['policy'];
    medicallUser.consent = datasnapshot.data['consent'];
    medicallUser.terms = datasnapshot.data['terms'];
    medicallUser.type = datasnapshot.data['type'];
    medicallUser.email = datasnapshot.data['email'];
    medicallUser.phoneNumber = datasnapshot.data['phone'];
    medicallUser.hasMedicalHistory = false;
    return medicallUser;
  }
}
