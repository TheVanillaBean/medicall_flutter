import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';

class SignInStateModel with EmailAndPasswordValidators, ChangeNotifier {
  String email;
  String password;
  bool autoValidate;
  bool isLoading;
  bool submitted;
  final AuthBase auth;

  SignInStateModel({
    @required this.auth,
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
      await auth.signInWithEmailAndPassword(this.email, this.password);
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future<MedicallUser> signInWithGoogle() async {
    updateWith(submitted: true, isLoading: true);
    try {
      return await auth.signInWithGoogle();
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateWith({
    String email,
    String password,
    bool autoValidate,
    bool isLoading,
    bool submitted,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.autoValidate = autoValidate ?? this.autoValidate;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
