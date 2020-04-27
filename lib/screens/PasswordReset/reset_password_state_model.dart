import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';

class ResetPasswordStateModel with EmailAndPasswordValidators, ChangeNotifier {
  final AuthBase auth;
  String email;
  bool isLoading;

  ResetPasswordStateModel({
    @required this.auth,
    this.email = '',
    this.isLoading = false,
  });

  bool get canSubmit {
    return emailValidator.isValid(email) && !isLoading;
  }

  String get emailErrorText {
    bool showErrorText = !emailValidator.isValid(email) && email.length > 0;
    return showErrorText ? invalidEmailErrorText : null;
  }

  void updateEmail(String email) => updateWith(email: email);

  Future<void> submit() async {
    updateWith(isLoading: true);
    try {
      await auth.resetPassword(email: this.email);
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateWith({
    String email,
    bool isLoading,
  }) {
    this.email = email ?? this.email;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
