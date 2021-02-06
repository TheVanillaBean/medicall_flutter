import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/screens/shared/login/apple_sign_in_model.dart';
import 'package:Medicall/screens/shared/login/google_auth_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:apple_sign_in/scope.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class RegistrationViewModel
    with
        EmailAndPasswordValidators,
        FirstNameValidators,
        LastNameValidators,
        DobValidators,
        ChangeNotifier {
  final NonAuthDatabase nonAuthDatabase;
  final AuthBase auth;
  final TempUserProvider tempUserProvider;

  String firstName;
  String lastName;
  DateTime birthDate = DateTime.now();
  String email;
  String password;
  String confirmPassword;
  bool checkValue;
  bool isLoading;
  bool submitted;
  GoogleAuthModel googleAuthModel;
  AppleSignInModel appleSignInModel;
  VerificationStatus verificationStatus;

  RegistrationViewModel({
    @required this.nonAuthDatabase,
    @required this.auth,
    @required this.tempUserProvider,
    this.lastName = '',
    this.firstName = '',
    this.birthDate,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.checkValue = false,
    this.isLoading = false,
    this.submitted = false,
  });

  void setVerificationStatus(VerificationStatus verificationStatus) {
    this.verificationStatus = verificationStatus;
  }

  bool get canSubmit {
    return firstNameValidator.isValid(firstName) &&
        lastNameValidator.isValid(lastName) &&
        dobValidator.isValid(birthDate) &&
        emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        !isLoading;
  }

  String get firstNameErrorText {
    bool showErrorText =
        this.submitted && !firstNameValidator.isValid(firstName);
    return showErrorText ? fNameErrorText : null;
  }

  String get lastNameErrorText {
    bool showErrorText = this.submitted && !lastNameValidator.isValid(lastName);
    return showErrorText ? lNameErrorText : null;
  }

  String get patientDobErrorText {
    bool showErrorText = this.submitted && !dobValidator.isValid(birthDate);
    return showErrorText ? dobErrorText : null;
  }

  String get birthday {
    final f = new DateFormat('MM/dd/yyyy');
    return this.birthDate.year <= DateTime.now().year - 18
        ? "${f.format(this.birthDate)}"
        : "Please Select";
  }

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String get confirmPasswordErrorText {
    bool showErrorText = submitted && confirmPassword != password;
    return showErrorText ? invalidConfirmPasswordErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : "";
  }

  void updateFirstName(String firstName) => updateWith(firstName: firstName);
  void updateLastName(String lastName) => updateWith(lastName: lastName);
  void updateBirthDate(DateTime birthDate) => updateWith(birthDate: birthDate);
  void updateEmail(String email) => updateWith(email: email);
  void updatePassword(String password) => updateWith(password: password);
  void updateConfirmPassword(String password) =>
      updateWith(confirmPassword: password);
  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);

  DateTime get initialDatePickerDate {
    final DateTime currentDate = DateTime.now();

    this.birthDate = this.birthDate == null ? currentDate : this.birthDate;

    return this.birthDate.year <= DateTime.now().year - 18
        ? this.birthDate
        : DateTime(
            currentDate.year - 18,
            currentDate.month,
            currentDate.day,
          );
  }

  Future<void> submit() async {
    updateWith(submitted: true);
    if (!checkValue) {
      this.verificationStatus.updateStatus(
          "You have to agree to the Terms and Conditions, as well as the Privacy Policy before signing in");
      return;
    }

    if (password != confirmPassword) {
      this.verificationStatus.updateStatus("Passwords do not match.");
      return;
    }

    try {
      updateWith(isLoading: true);
      bool emailAlreadyUsed = await auth.emailAlreadyUsed(email: this.email);
      if (!emailAlreadyUsed) {
        this.auth.triggerAuthStream = false;
        this.verificationStatus.updateStatus(
            'Saving User Details. This may take several seconds...');
        User user = await auth.createUserWithEmailAndPassword(
            email: this.email, password: this.password);
        tempUserProvider.user.uid = user.uid;
        tempUserProvider.user.email = this.email;
        tempUserProvider.user.firstName = this.firstName;
        tempUserProvider.user.lastName = this.lastName;
        tempUserProvider.user.dob = this.birthday;
        updateWith(submitted: false, isLoading: false);
        saveUserDetails(user);
      } else {
        throw PlatformException(
            code: 'AUTH_ERROR', message: 'This email address is taken.');
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signInWithApplePressed(BuildContext context) async {
    updateWith(submitted: true, isLoading: true);
    try {
      AppleSignInModel appleSignInModel = await auth
          .fetchAppleSignInCredential(scopes: [Scope.email, Scope.fullName]);

      if (appleSignInModel.credential != null) {
        this.auth.triggerAuthStream = false;
        this.verificationStatus.updateStatus(
            'Saving User Details. This may take several seconds...');
        User user = await auth.signInWithApple(
            appleIdCredential: appleSignInModel.credential);
        tempUserProvider.setUser(userType: USER_TYPE.PATIENT);
        tempUserProvider.user.uid = user.uid;
        tempUserProvider.user.email = appleSignInModel.email;

        updateWith(
            appleSignInModel: appleSignInModel,
            submitted: false,
            isLoading: false);

        saveUserDetails(user);
      }
    } catch (e) {
      updateWith(submitted: false, isLoading: false);
      rethrow;
    }
  }

  Future<void> signInWithGooglePressed(context) async {
    updateWith(submitted: true, isLoading: true);
    try {
      GoogleAuthModel googleAuthModel =
          await auth.fetchGoogleSignInCredential();

      if (googleAuthModel.credential != null) {
        this.auth.triggerAuthStream = false;
        this.verificationStatus.updateStatus(
            'Saving User Details. This may take several seconds...');
        User user = await auth.signInWithGoogle(
          credential: googleAuthModel.credential,
        );
        tempUserProvider.setUser(userType: USER_TYPE.PATIENT);
        tempUserProvider.user.uid = user.uid;
        tempUserProvider.user.email = googleAuthModel.email;
        updateWith(
            googleAuthModel: googleAuthModel,
            submitted: false,
            isLoading: false);
        saveUserDetails(user);
      }
    } catch (e) {
      updateWith(submitted: false, isLoading: false);
      rethrow;
    }
  }

  void saveUserDetails(User user) async {
    await this.addNewUserToFirestore();
    this.auth.addUserToAuthStream(user: user);
  }

  Future<void> addNewUserToFirestore() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String token = await _firebaseMessaging.getToken();
    tempUserProvider.user.devTokens = [token];
    await nonAuthDatabase.setUser(tempUserProvider.user);
  }

  void updateWith({
    String firstName,
    String lastName,
    DateTime birthDate,
    String email,
    String password,
    String confirmPassword,
    bool checkValue,
    bool isLoading,
    bool submitted,
    GoogleAuthModel googleAuthModel,
    AppleSignInModel appleSignInModel,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.birthDate = birthDate ?? this.birthDate;
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.confirmPassword = confirmPassword ?? this.confirmPassword;
    this.checkValue = checkValue ?? this.checkValue;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.googleAuthModel = googleAuthModel ?? this.googleAuthModel;
    this.appleSignInModel = appleSignInModel ?? this.appleSignInModel;
    notifyListeners();
  }
}

mixin VerificationStatus {
  void updateStatus(String msg);
}
