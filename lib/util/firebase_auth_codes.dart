class FirebaseAuthCodes {
  static const String ERROR_WEAK_PASSWORD = "ERROR_WEAK_PASSWORD";
  static const String ERROR_INVALID_EMAIL = "ERROR_WEAK_PASSWORD";
  static const String ERROR_EMAIL_ALREADY_IN_USE = "ERROR_WEAK_PASSWORD";
  static const String ERROR_WRONG_PASSWORD = "ERROR_WEAK_PASSWORD";
  static const String ERROR_USER_NOT_FOUND = "ERROR_USER_NOT_FOUND";
  static const String ERROR_USER_DISABLED = "ERROR_USER_DISABLED";
  static const String ERROR_TOO_MANY_REQUESTS = "ERROR_USER_TOKEN_EXPIRED";
  static const String ERROR_OPERATION_NOT_ALLOWED = "ERROR_USER_TOKEN_EXPIRED";
  static const String ERROR_USER_TOKEN_EXPIRED = "ERROR_USER_TOKEN_EXPIRED";

  static Map<String, String> errors = {
    ERROR_WEAK_PASSWORD: 'If the password is not strong enough.',
    ERROR_INVALID_EMAIL: 'If the email address is malformed.',
    ERROR_EMAIL_ALREADY_IN_USE:
        'If the email is already in use by a different account.',
    ERROR_WRONG_PASSWORD: 'If the [password] is wrong.',
    ERROR_USER_NOT_FOUND:
        'If there is no user corresponding to the given [email] address, or if the user has been deleted.',
    ERROR_USER_DISABLED:
        'If the user has been disabled (for example, in the Firebase console)',
    ERROR_TOO_MANY_REQUESTS:
        'If there was too many attempts to sign in as this user.',
    ERROR_OPERATION_NOT_ALLOWED:
        'Indicates that Email & Password accounts are not enabled.',
    ERROR_USER_TOKEN_EXPIRED: 'The user token for this user has expired.',
  };
}
