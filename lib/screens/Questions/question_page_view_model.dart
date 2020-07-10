import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';

class QuestionPageViewModel with OptionInputValidator, ChangeNotifier {
  Question question;
  QuestionsViewModel questionsViewModel;
  String input;
  bool submitted;
  List<String> optionsList = [];
  List<String> selectedOptionsList = [];

  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  QuestionPageViewModel({
    this.input = '',
    this.submitted = false,
    this.question,
    this.questionsViewModel,
  }) {
    getOptionsList(question);
    getInput();
  }

  void getOptionsList(Question question) {
    optionsList.clear();
    for (Option opt in question.options) {
      optionsList.add(opt.value);
    }

    if (question.type == Q_TYPE.MC && question.answer != null) {
      List<String> selectedList = [];
      for (var answer in question.answer.answer) {
        selectedList.add(answer);
      }
      selectedOptionsList = selectedList;
    }
  }

  void previousPage() async {
    questionsViewModel.previousPage();
  }

  void nextPage(Question question) async {
    Answer answer;
    if (question.type == Q_TYPE.MC) {
      answer = Answer(answer: List.of(selectedOptionsList));
    } else {
      answer = Answer(answer: [input]);
    }

    question.answer = answer;
    selectedOptionsList.clear();
    input = "";
    questionsViewModel.nextPage();
  }

  bool get canSubmitInputField {
    return inputValidator.isValid(input);
  }

  String get inputErrorText {
    bool showErrorText = submitted && !inputValidator.isValid(input);
    return showErrorText ? inputErrorText : null;
  }

  void getInput() {
    if (question.type == Q_TYPE.FR && question.answer != null) {
      input = question.answer.answer.first;
      inputController.text = input;
      inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: inputController.text.length),
      );
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
    notifyListeners();
  }
}
