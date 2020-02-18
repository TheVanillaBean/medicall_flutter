import 'dart:typed_data';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TempUserProvider {
  MedicallUser _medicallUser;
  List<Asset> _images;
  String _password;
  GoogleAuthModel _googleAuthModel;

  MedicallUser get medicallUser {
    return _medicallUser;
  }

  void setMedicallUser(MedicallUser user){
    _medicallUser = user;
  }

  List<Asset> get images {
    return _images;
  }

  String get password {
    return _password;
  }

  GoogleAuthModel get googleAuthModel {
    return _googleAuthModel;
  }

  void setGoogleAuthModel(GoogleAuthModel model){
    _googleAuthModel = model;
  }

  TempUserProvider() {
    _medicallUser = MedicallUser();
  }

  void updateWith({
    String uid,
    List<dynamic> devTokens,
    String phoneNumber,
    String userType,
    String displayName,
    String firstName,
    String lastName,
    String dob,
    String gender,
    String email,
    bool terms,
    bool policy,
    bool consent,
    String titles,
    String npi,
    String medLicense,
    String medLicenseState,
    String address,
    List<Asset> images,
    String password,
    GoogleAuthModel googleAuthModel,
  }) {
    this._medicallUser.uid = uid ?? this._medicallUser.uid;
    this._medicallUser.devTokens = devTokens ?? this._medicallUser.devTokens;
    this._medicallUser.phoneNumber =
        phoneNumber ?? this._medicallUser.phoneNumber;
    this._medicallUser.displayName =
        displayName ?? this._medicallUser.displayName;
    this._medicallUser.firstName = firstName ?? this._medicallUser.firstName;
    this._medicallUser.lastName = lastName ?? this._medicallUser.lastName;
    this._medicallUser.type = userType ?? this._medicallUser.type;
    this._medicallUser.dob = dob ?? this._medicallUser.dob;
    this._medicallUser.gender = gender ?? this._medicallUser.gender;
    this._medicallUser.email = email ?? this._medicallUser.email;
    this._medicallUser.terms = terms ?? this._medicallUser.terms;
    this._medicallUser.policy = policy ?? this._medicallUser.policy;
    this._medicallUser.consent = consent ?? this._medicallUser.consent;
    this._medicallUser.titles = titles ?? this._medicallUser.titles;
    this._medicallUser.npi = npi ?? this._medicallUser.npi;
    this._medicallUser.medLicense = medLicense ?? this._medicallUser.medLicense;
    this._medicallUser.medLicenseState =
        medLicenseState ?? this._medicallUser.medLicenseState;
    this._medicallUser.address = address ?? this._medicallUser.address;
    this._images = images ?? this._images;
    this._password = password ?? this._password;
    this._googleAuthModel = googleAuthModel ?? this._googleAuthModel;
  }

  Future<bool> saveRegistrationImages() async {
    if (this.medicallUser.uid.length > 0) {
      var assets = this.images;
      var allMediaList = [];
      for (var i = 0; i < assets.length; i++) {
        ByteData byteData = await assets[i].getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        StorageReference ref = FirebaseStorage.instance
            .ref()
            .child("profile/" + medicallUser.uid + '/' + assets[i].name);
        StorageUploadTask uploadTask = ref.putData(imageData);

        allMediaList.add(
          await (await uploadTask.onComplete).ref.getDownloadURL(),
        );
      }

      medicallUser.profilePic = allMediaList[0];
      medicallUser.govId = allMediaList[1];
      return true;
    }
    return false;
  }

  Future<void> addNewUserToFirestore() async {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + medicallUser.uid);
    Map<String, dynamic> data = <String, dynamic>{
      "name": medicallUser.displayName,
      "first_name": medicallUser.firstName,
      "last_name": medicallUser.lastName,
      "email": medicallUser.email,
      "gender": medicallUser.gender,
      "type": medicallUser.type,
      "address": medicallUser.address,
      "terms": medicallUser.terms,
      "policy": medicallUser.policy,
      "consent": medicallUser.consent,
      "dob": medicallUser.dob,
      "phone": medicallUser.phoneNumber,
      "profile_pic": medicallUser.profilePic,
      "gov_id": medicallUser.govId,
      "dev_tokens": medicallUser.devTokens,
      "type": medicallUser.type,
    };
    if (medicallUser.type == 'provider') {
      data['titles'] = medicallUser.titles;
      data['npi'] = medicallUser.npi;
      data['med_license'] = medicallUser.medLicense;
      data['state_issued'] = medicallUser.medLicenseState;
    }
    try {
      await documentReference.setData(data);
    } catch (e) {
      rethrow;
    }
  }
}
