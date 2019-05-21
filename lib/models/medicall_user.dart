library medicall_user;


MedicallUser medicallUser;

class MedicallUser {
  String id;
  String type;
  String displayName;
  String firstName;
  String lastName;
  String dob;
  String phoneNumber;
  String email;
  bool terms;
  bool policy;

  MedicallUser({
    this.id,
    this.type,
    this.displayName,
    this.firstName,
    this.lastName,
    this.dob,
    this.phoneNumber,
    this.email,
    this.terms,
    this.policy,
  });
}