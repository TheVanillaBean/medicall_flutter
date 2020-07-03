import 'package:Medicall/models/user_model_base.dart';

class PatientUser extends User {
  String type;
  String govId;
  bool hasMedicalHistory;

  PatientUser({
    this.type = 'Patient',
    this.govId = '',
    this.hasMedicalHistory = false,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.baseToMap();
    userMap.addAll({
      "type": type,
      'gov_id': govId,
      'hasMedicalHistory': hasMedicalHistory,
    });
    return userMap;
  }

  static PatientUser fromMap(String uid, Map<String, dynamic> data) {
    PatientUser patientUser = PatientUser();
    patientUser.govId = data['gov_id'] ?? patientUser.govId;
    patientUser.type = data['type'] ?? patientUser.type;
    patientUser.hasMedicalHistory =
        data['hasMedicalHistory'] ?? patientUser.hasMedicalHistory;
    return patientUser;
  }
}
