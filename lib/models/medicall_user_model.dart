MedicallUser medicallUser;

class MedicallUser {
  String id;
  List<dynamic> devTokens;
  String type;
  String displayName;
  String firstName;
  String lastName;
  String dob;
  String phoneNumber;
  String email;
  String address;
  String titles;
  bool terms;
  bool policy;
  bool consent;

  MedicallUser({
    this.id,
    this.devTokens,
    this.type,
    this.displayName,
    this.firstName,
    this.lastName,
    this.dob,
    this.phoneNumber,
    this.email,
    this.address,
    this.titles,
    this.terms,
    this.policy,
    this.consent,
  });
}
