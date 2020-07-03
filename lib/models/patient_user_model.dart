import 'package:Medicall/models/user_model_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Patient extends User {
  String type;
  String address;
  String govId;
  bool hasMedicalHistory;

  Patient({
    this.type = 'Patient',
    this.address = '',
    this.govId = '',
    this.hasMedicalHistory = false,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.toMap();
    userMap.addAll({
      'address': address,
      "type": type,
      'gov_id': govId,
      'hasMedicalHistory': hasMedicalHistory,
    });
    return userMap;
  }

  factory Patient.fromMap(String uid, DocumentSnapshot snapshot) {
    Patient patientUser = User.fromMap(uid, snapshot);
    patientUser.address = snapshot.data['address'] ?? patientUser.address;
    patientUser.govId = snapshot.data['gov_id'] ?? patientUser.govId;
    patientUser.type = snapshot.data['type'] ?? patientUser.type;
    patientUser.hasMedicalHistory = false;
    return patientUser;
  }
}
