MedicallUser medicallUser;

class MedicallUser {
  String id;
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
    this.id,
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
}
