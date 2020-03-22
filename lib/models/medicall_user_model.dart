import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.uid = '',
    this.devTokens = const ['', ''],
    this.type = '',
    this.displayName = '',
    this.firstName = '',
    this.lastName = '',
    this.dob = '',
    this.gender = '',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.titles = '',
    this.npi = '',
    this.medLicense = '',
    this.medLicenseState = '',
    this.profilePic = '',
    this.govId = '',
    this.terms = false,
    this.policy = false,
    this.consent = false,
    this.hasMedicalHistory = false,
  });

  factory MedicallUser.from(String uid, DocumentSnapshot snapshot) {
    MedicallUser medicallUser = MedicallUser();
    medicallUser.uid = uid ?? medicallUser.uid;
    medicallUser.displayName =
        snapshot.data['name'] ?? medicallUser.displayName;
    medicallUser.firstName =
        snapshot.data['first_name'] ?? medicallUser.firstName;
    medicallUser.lastName = snapshot.data['last_name'] ?? medicallUser.lastName;
    medicallUser.address = snapshot.data['address'] ?? medicallUser.address;
    medicallUser.devTokens =
        snapshot.data['dev_tokens'] ?? medicallUser.devTokens;
    medicallUser.dob = snapshot.data['dob'] ?? medicallUser.dob;
    medicallUser.gender = snapshot.data['gender'] ?? medicallUser.gender;
    medicallUser.policy = snapshot.data['policy'] ?? medicallUser.policy;
    medicallUser.consent = snapshot.data['consent'] ?? medicallUser.consent;
    medicallUser.terms = snapshot.data['terms'] ?? medicallUser.terms;
    medicallUser.profilePic =
        snapshot.data['profile_pic'] ?? medicallUser.profilePic;
    medicallUser.govId = snapshot.data['gov_id'] ?? medicallUser.govId;
    medicallUser.titles = snapshot.data['titles'] ?? medicallUser.titles;
    medicallUser.type = snapshot.data['type'] ?? medicallUser.type;
    medicallUser.email = snapshot.data['email'] ?? medicallUser.email;
    medicallUser.phoneNumber =
        snapshot.data['phone' ?? medicallUser.phoneNumber];
    medicallUser.hasMedicalHistory = false;
    return medicallUser;
  }
}
