import 'package:Medicall/models/user_model_base.dart';

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
    Map<String, dynamic> userMap = super.baseToMap();
    userMap.addAll({
      'address': address,
      "type": type,
      'gov_id': govId,
      'hasMedicalHistory': hasMedicalHistory,
    });
    return userMap;
  }

  static Patient fromMap(String uid, Map<String, dynamic> data) {
    Patient patientUser = Patient();
    patientUser.address = data['address'] ?? patientUser.address;
    patientUser.govId = data['gov_id'] ?? patientUser.govId;
    patientUser.type = data['type'] ?? patientUser.type;
    patientUser.hasMedicalHistory =
        data['hasMedicalHistory'] ?? patientUser.hasMedicalHistory;
    return patientUser;
  }
}
