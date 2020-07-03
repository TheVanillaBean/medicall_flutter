class FirestorePath {
  static String consult(String consultID) => 'consults/$consultID';
  static String users() => 'users/';
  static String user(String uid) => 'users/$uid/';
  static String medicalHistory(String uid) => 'medical_history/$uid';
  static String symptoms() => 'services/dermatology/symptoms_list';
  static String screeningQuestions(String symptom) =>
      'services/dermatology/symptoms_list/$symptom/screening-questions/';
  static String consultQuestions(String type) =>
      'services/dermatology/symptoms/$type';

  //Firebase Storage
  static String userProfileImage({String uid, String assetName}) =>
      'profile/$uid/$assetName.JPG';
}
