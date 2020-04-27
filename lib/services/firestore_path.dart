class FirestorePath {
  static String consult(String consultID) => 'consults/$consultID';
  static String user(String uid) => 'users/$uid/';
  static String paymentCard(String uid) => 'cards/$uid/sources';
  static String medicalHistory(String uid) => 'medical_history/$uid';
  static String consultQuestions(String type) =>
      'services/dermatology/symptoms/$type';
}
