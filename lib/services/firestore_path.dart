class FirestorePath {
  static String version() => 'version-management/version_info';
  static String users() => 'users/';
  static String user(String uid) => 'users/$uid/';
  static String waitList(String email) => 'waitlist/$email/';
  static String coupon(String code) => 'coupons/$code/';
  static String medicalHistory(String uid) =>
      'users/$uid/medical_history/questions/';
  static String symptoms() => 'services/dermatology/symptoms/';
  static String symptom(String symptom) =>
      'services/dermatology/symptoms/$symptom';
  static String screeningQuestions(String symptom) =>
      'services/dermatology/symptoms/$symptom/questionaire/';
  static String consults() => 'consults/';
  static String consult(String consultID) => 'consults/$consultID';
  static String questionnaire(String consultID) =>
      'consults/$consultID/questionnaire/questions/';
  static String prescriptions(String consultID, String prescriptionID) =>
      'consults/$consultID/prescriptions/$prescriptionID';
  static String consultReviewOptions(String symptom) =>
      'services/dermatology/symptoms/$symptom/review-options/options/';
  static String consultReviewOptionsDiagnosis(
          String symptom, String diagnosis) =>
      'services/dermatology/symptoms/$symptom/review-options/diagnoses-list/$diagnosis/diagnosis';
  static String visitReview(String consultId) =>
      'consults/$consultId/visit-review/original/';

  //Firebase Storage
  static String userProfileImage({String uid, String assetName}) =>
      'profile/$uid/$assetName.JPG';
  static String consultPhotoQuestion({String consultID, String assetName}) =>
      'consults/$consultID/$assetName.JPG';
  static String symptomPhoto({String symptom}) => 'symptom-photos/$symptom/';
}
