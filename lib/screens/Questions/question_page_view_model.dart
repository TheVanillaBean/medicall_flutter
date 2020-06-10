import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';

class QuestionPageViewModel with OptionInputValidator, ChangeNotifier {
  String input;
  bool autoValidate;
  bool isLoading;
  bool submitted;

  QuestionPageViewModel({
    this.input = '',
    this.autoValidate = false,
    this.isLoading = false,
    this.submitted = false,
  });

  bool get canSubmit {
    return inputValidator.isValid(input) && !isLoading;
  }

  String get inputErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(input);
    return showErrorText ? inputErrorText : null;
  }

  void updateInput(String input) => updateWith(input: input);

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {} catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateWith({
    String input,
    bool autoValidate,
    bool isLoading,
    bool submitted,
  }) {
    this.input = input ?? this.input;
    this.autoValidate = autoValidate ?? this.autoValidate;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
