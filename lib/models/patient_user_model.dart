import 'package:Medicall/models/user_model_base.dart';

class PatientUser extends User {
  String govId;
  bool hasMedicalHistory;

  PatientUser({
    this.govId = '',
    this.hasMedicalHistory = false,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.baseToMap();
    userMap.addAll({
      'gov_id': govId,
      'hasMedicalHistory': hasMedicalHistory,
    });
    return userMap;
  }

  static PatientUser fromMap(String uid, Map<String, dynamic> data) {
    PatientUser patientUser = PatientUser();
    patientUser.govId = data['gov_id'] ?? patientUser.govId;
    patientUser.hasMedicalHistory =
        data['hasMedicalHistory'] ?? patientUser.hasMedicalHistory;
    return patientUser;
  }
}
