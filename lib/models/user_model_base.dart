import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  List<dynamic> devTokens;
  String fullName;
  String firstName;
  String lastName;
  String dob;
  String gender;
  String phoneNumber;
  String email;
  String profilePic;

  User({
    this.uid = '',
    this.devTokens = const ['', ''],
    this.fullName = '',
    this.firstName = '',
    this.lastName = '',
    this.dob = '',
    this.gender = '',
    this.phoneNumber = '',
    this.email = '',
    this.profilePic = '',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'dev_tokens': devTokens,
      'dob': dob,
      'gender': gender,
      'profile_pic': profilePic,
      'phone_number': phoneNumber,
    };
  }

  factory User.fromMap(String uid, DocumentSnapshot snapshot) {
    User user = User();
    user.uid = uid ?? user.uid;
    user.firstName = snapshot.data['first_name'] ?? user.firstName;
    user.lastName = snapshot.data['last_name'] ?? user.lastName;
    user.fullName = '${user.firstName} ${user.lastName}' ?? "";
    user.devTokens = snapshot.data['dev_tokens'] ?? user.devTokens;
    user.dob = snapshot.data['dob'] ?? user.dob;
    user.gender = snapshot.data['gender'] ?? user.gender;
    user.profilePic = snapshot.data['profile_pic'] ?? user.profilePic;
    user.email = snapshot.data['email'] ?? user.email;
    user.phoneNumber = snapshot.data['phone_number'] ?? user.phoneNumber;
    return user;
  }
}
