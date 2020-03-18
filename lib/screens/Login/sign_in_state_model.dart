import 'package:Medicall/screens/Login/apple_sign_in_model.dart';
import 'package:Medicall/screens/Login/google_auth_model.dart';
import 'package:Medicall/services/animation_provider.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/validators.dart';
import 'package:apple_sign_in/scope.dart';
import 'package:flutter/material.dart';

class SignInStateModel with EmailAndPasswordValidators, ChangeNotifier {
  String email;
  String password;
  bool autoValidate;
  bool isLoading;
  bool submitted;
  GoogleAuthModel googleAuthModel;
  AppleSignInModel appleSignInModel;
  final AuthBase auth;
  final TempUserProvider tempUserProvider;
  final MyAnimationProvider animationProvider;

  SignInStateModel({
    @required this.auth,
    @required this.tempUserProvider,
    @required this.animationProvider,
    this.email = '',
    this.password = '',
    this.autoValidate = false,
    this.isLoading = false,
    this.submitted = false,
  });

  bool get canSubmit {
    return emailValidator.isValid(email) &&
        passwordValidator.isValid(password) &&
        !isLoading;
  }

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  void updateEmail(String email) => updateWith(email: email);
  void updatePassword(String password) => updateWith(password: password);

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      await auth.signInWithEmailAndPassword(
          email: this.email, password: this.password);
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

      if (appleSignInModel.providers != null &&
          appleSignInModel.providers.length > 0) {
        if (appleSignInModel.providers.contains("apple.com")) {
          await auth.signInWithApple(
              appleIdCredential: appleSignInModel.credential);
        } else {
          AppUtil().showFlushBar(
              "Account already linked with different sign in method, please sign in using Apple or Google.",
              context);
          updateWith(submitted: false, isLoading: false);
        }
      } else {
        updateWith(
            appleSignInModel: appleSignInModel,
            submitted: false,
            isLoading: false);
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

      if (googleAuthModel.providers != null &&
          googleAuthModel.providers.length > 0) {
        if (googleAuthModel.providers.contains("google.com")) {
          await auth.signInWithGoogle(credential: googleAuthModel.credential);
        } else {
          AppUtil().showFlushBar(
              "Account already linked with different sign in method, please sign in using Apple or Google.",
              context);
          updateWith(submitted: false, isLoading: false);
        }
      } else {
        updateWith(
            googleAuthModel: googleAuthModel,
            submitted: false,
            isLoading: false);
      }
    } catch (e) {
      updateWith(submitted: false, isLoading: false);
      rethrow;
    }
  }

  void updateWith({
    String email,
    String password,
    bool autoValidate,
    bool isLoading,
    bool submitted,
    GoogleAuthModel googleAuthModel,
    AppleSignInModel appleSignInModel,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.autoValidate = autoValidate ?? this.autoValidate;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    this.googleAuthModel = googleAuthModel ?? this.googleAuthModel;
    this.appleSignInModel = appleSignInModel ?? this.appleSignInModel;
    notifyListeners();
  }
}
