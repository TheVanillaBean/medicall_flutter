class FirestorePath {
  static String users() => 'users/';
  static String user(String uid) => 'users/$uid/';
  static String medicalHistory(String uid) =>
      'users/$uid/medical_history/questions/';
  static String symptoms() => 'parsed-symptoms-list/';
  static String screeningQuestions(String symptom) =>
      'parsed-symptoms-list/$symptom/questionaire/';
  static String consults() => 'consults/';
  static String consult(String consultID) => 'consults/$consultID';
  static String questionnaire(String consultID) =>
      'consults/$consultID/questionnaire/questions/';
  static String prescriptions(String consultID) =>
      'consults/$consultID/prescriptions/prescriptions/';
  static String consultReviewOptions(String symptom) =>
      'parsed-symptoms-list/$symptom/review-options/options/';
  static String consultReviewOptionsDiagnosis(
          String symptom, String diagnosis) =>
      'parsed-symptoms-list/$symptom/review-options/diagnoses-list/$diagnosis/diagnosis';
  static String visitReview(String consultId) =>
      'consults/$consultId/visit-review/original/';

  //Firebase Storage
  static String userProfileImage({String uid, String assetName}) =>
      'profile/$uid/$assetName.JPG';
  static String consultPhotoQuestion({String consultID, String assetName}) =>
      'consults/$consultID/$assetName.JPG';
}
