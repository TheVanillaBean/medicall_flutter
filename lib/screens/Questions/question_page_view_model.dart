import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';

class QuestionPageViewModel with OptionInputValidator, ChangeNotifier {
  final QuestionsViewModel questionsViewModel;

  Question question;
  String input;
  bool submitted;
  List<String> optionsList = [];
  List<String> selectedOptionsList = [];

  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  QuestionPageViewModel({
    @required this.questionsViewModel,
    this.input = '',
    this.submitted = false,
    this.question,
  }) {
    getOptionsList(question);
    getInput();
  }

  void getOptionsList(Question question) {
    optionsList.clear();
    for (Option opt in question.options) {
      optionsList.add(opt.value);
    }

    if (question.type == "MC" && question.answer != null) {
      List<String> selectedList = [];
      for (var answer in question.answer.answer) {
        selectedList.add(answer);
      }
      selectedOptionsList = selectedList;
    }
  }

  bool get canSubmitInputField {
    return inputValidator.isValid(input);
  }

  String get inputErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(input);
    return showErrorText ? inputErrorText : null;
  }

  void getInput() {
    if (question.type == "FR" && question.answer != null) {
      input = question.answer.answer.first;
      inputController.text = input;
      inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: inputController.text.length));
    }
  }

  void updateInput(String input) => updateWith(input: input);
  void checkedItemsChanged(List<String> items) =>
      updateWith(selectedOptionsList: items);

  void updateWith({
    List<String> selectedOptionsList,
    String input,
    bool submitted,
  }) {
    this.input = input ?? this.input;
    this.selectedOptionsList = selectedOptionsList ?? this.selectedOptionsList;
    this.submitted = submitted ?? this.submitted;
    questionsViewModel.updateWith(progress: 1);
    notifyListeners();
  }
}
