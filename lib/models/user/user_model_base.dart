import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum USER_TYPE { NOT_SET, PROVIDER, PATIENT }

//This class acts as a baseclass for both types of users: patient and provider
abstract class MedicallUser {
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
  String mailingAddress;
  String mailingState;
  String mailingZipCode;
  String mailingCity;
  String shippingAddress;
  String shippingState;
  String shippingZipCode;
  String shippingCity;
  String streamChatID;

  MedicallUser({
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
    this.mailingAddress = '',
    this.mailingState = '',
    this.mailingZipCode = '',
    this.mailingCity = '',
    this.shippingAddress = '',
    this.shippingState = '',
    this.shippingZipCode = '',
    this.shippingCity = '',
    this.streamChatID = '',
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
      'mailing_address': mailingAddress,
      'mailing_state': mailingState,
      'mailing_zip_code': mailingZipCode,
      'mailing_city': mailingCity,
      'shipping_address': shippingAddress,
      'shipping_state': shippingState,
      'shipping_zip_code': shippingZipCode,
      'shipping_city': shippingCity,
    };
  }

  factory MedicallUser.fromMap({
    USER_TYPE userType,
    String uid,
    Map<String, dynamic> data,
  }) {
    MedicallUser user;
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
    user.mailingAddress = data['mailing_address'] ?? user.mailingAddress;
    user.mailingState = data['mailing_state'] ?? user.mailingState;
    user.mailingZipCode = data['mailing_zip_code'] ?? user.mailingZipCode;
    user.mailingCity = data['mailing_city'] ?? user.mailingCity;
    user.shippingAddress = data['shipping_address'] ?? user.shippingAddress;
    user.shippingState = data['shipping_state'] ?? user.shippingState;
    user.shippingZipCode = data['shipping_zip_code'] ?? user.shippingZipCode;
    user.shippingCity = data['shipping_city'] ?? user.shippingCity;
    user.streamChatID = data['stream_chat_id'] ?? user.streamChatID;
    return user;
  }
}
