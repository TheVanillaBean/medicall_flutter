class FirestorePath {
  static String consult(String consultID) => 'consults/$consultID';
  static String user(String uid) => 'users/$uid/';
  static String medicalHistory(String uid) => 'medical_history/$uid';
  static String symptoms() => 'services/dermatology/symptoms';
  static String consultQuestions(String type) =>
      'services/dermatology/symptoms/$type';
}
