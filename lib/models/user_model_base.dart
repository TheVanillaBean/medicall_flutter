import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum USER_TYPE { NOT_SET, PROVIDER, PATIENT }

//This class acts as a baseclass for both types of users: patient and provider
abstract class User {
  String uid;
  USER_TYPE type;
  List<dynamic> devTokens; //used for push notifs
  String fullName;
  String firstName;
  String lastName;
  String dob;
  String gender;
  String phoneNumber;
  String email;
  String profilePic;
  String address;
  String state;
  String zipCode;
  String city;

  User({
    this.uid = '',
    this.type = USER_TYPE.NOT_SET,
    this.devTokens = const ['', ''],
    this.fullName = '',
    this.firstName = '',
    this.lastName = '',
    this.dob = '',
    this.gender = '',
    this.phoneNumber = '',
    this.email = '',
    this.profilePic = '',
    this.address = '',
    this.state = '',
    this.zipCode = '',
    this.city = '',
  });

  Map<String, dynamic> toMap();

  Map<String, dynamic> baseToMap() {
    return <String, dynamic>{
      'uid': uid,
      'type': EnumToString.parse(type),
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'dev_tokens': devTokens,
      'dob': dob,
      'gender': gender,
      'profile_pic': profilePic,
      'phone_number': phoneNumber,
      'address': address,
      'state': state,
      'zipCode': zipCode,
      'city': city,
    };
  }

  factory User.fromMap({
    USER_TYPE userType,
    String uid,
    Map<String, dynamic> data,
  }) {
    User user;
    if (userType == USER_TYPE.PATIENT) {
      user = PatientUser.fromMap(uid, data);
      user.type = USER_TYPE.PATIENT;
    } else {
      user = ProviderUser.fromMap(uid, data);
      user.type = USER_TYPE.PROVIDER;
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
    user.address = data['address'] ?? user.address;
    user.state = data['state'] ?? user.state;
    user.zipCode = data['zipCode'] ?? user.zipCode;
    user.city = data['city'] ?? user.city;
    return user;
  }
}
