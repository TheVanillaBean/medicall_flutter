import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';

//This class acts as a baseclass for both types of users: patient and provider
abstract class User {
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

  Map<String, dynamic> toMap();

  Map<String, dynamic> baseToMap() {
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

  factory User.fromMap(
      {String userType, String uid, Map<String, dynamic> data}) {
    User user;
    if (userType == 'Patient') {
      user = Patient.fromMap(uid, data);
    } else {
      user = Provider.fromMap(uid, data);
    }
    user.uid = uid ?? user.uid;
    user.firstName = data['first_name'] ?? user.firstName;
    user.lastName = data['last_name'] ?? user.lastName;
    user.fullName = '${user.firstName} ${user.lastName}' ?? "";
    user.devTokens = data['dev_tokens'] ?? user.devTokens;
    user.dob = data['dob'] ?? user.dob;
    user.gender = data['gender'] ?? user.gender;
    user.profilePic = data['profile_pic'] ?? user.profilePic;
    user.email = data['email'] ?? user.email;
    user.phoneNumber = data['phone_number'] ?? user.phoneNumber;
    return user;
  }
}
