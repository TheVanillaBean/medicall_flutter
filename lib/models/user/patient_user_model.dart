import 'package:Medicall/models/user/user_model_base.dart';

class PatientUser extends MedicallUser {
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
      'has_medical_history': hasMedicalHistory,
    });
    return userMap;
  }

  static PatientUser fromMap(String uid, Map<String, dynamic> data) {
    PatientUser patientUser = PatientUser();
    patientUser.govId = data['gov_id'] ?? patientUser.govId;
    patientUser.hasMedicalHistory =
        data['has_medical_history'] ?? patientUser.hasMedicalHistory;
    return patientUser;
  }
}
