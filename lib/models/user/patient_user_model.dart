import 'package:Medicall/models/user/user_model_base.dart';

class PatientUser extends MedicallUser {
  String govId;
  bool hasMedicalHistory;
  String insurance;
  String memberId;

  PatientUser({
    this.govId = '',
    this.hasMedicalHistory = false,
    this.insurance = '',
    this.memberId = '',
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> userMap = super.baseToMap();
    userMap.addAll({
      'gov_id': govId,
      'has_medical_history': hasMedicalHistory,
      'insurance': insurance,
      'member_id': memberId,
    });
    return userMap;
  }

  static PatientUser fromMap(String uid, Map<String, dynamic> data) {
    PatientUser patientUser = PatientUser();
    patientUser.govId = data['gov_id'] ?? patientUser.govId;
    patientUser.hasMedicalHistory =
        data['has_medical_history'] ?? patientUser.hasMedicalHistory;
    patientUser.insurance = data['insurance'] ?? patientUser.insurance;
    patientUser.memberId = data['member_id'] ?? patientUser.memberId;
    return patientUser;
  }
}
