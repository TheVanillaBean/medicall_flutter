import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class QuestionsViewModel with OptionInputValidator, ChangeNotifier {
  final AuthBase auth;
  final Symptom symptom;
  final Consult consult;
  final PageController controller = PageController();

  double _progress = 0;
  Option _selected;

  //Question State Fields
  String input;
  bool autoValidate;
  bool isLoading;
  bool submitted;

  List<String> optionsCheckedList;

  List<String> getOptionsList(Question question) {
    List<String> options = [];
    for (Option opt in question.options) {
      options.add(opt.value);
    }
    return options;
  }

  QuestionsViewModel({
    @required this.auth,
    @required this.symptom,
    @required this.consult,
    this.input = '',
    this.autoValidate = false,
    this.isLoading = false,
    this.submitted = false,
  });

  get progress => _progress;
  get selected => _selected;

  set progress(double newValue) {
    _progress = newValue;
    notifyListeners();
  }

  set selected(Option newValue) {
    _selected = newValue;
    notifyListeners();
  }

  void nextPage() async {
    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

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
