import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

// Properties
abstract class QuestionVMProperties {
  static String get questionProgressBar => 'progress_bar';
  static String get questionNavButtons => 'nav_buttons';
  static String get questionPage => 'page';
  static String get questionScreen => 'root_screen'; //i.e root
}

class QuestionsViewModel extends PropertyChangeNotifier
    with OptionInputValidator {
  final AuthBase auth;
  final Consult consult;
  final PageController controller = PageController();
  double progress;

  //Question Page
  String input;
  List<String> optionsList = [];
  List<String> selectedOptionsList = [];
  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  QuestionsViewModel({
    @required this.auth,
    @required this.consult,
    this.progress = 0.0,
    this.input = '',
  });

  void nextPage() async {
    Question question = this.consult.questions[this
        .controller
        .page
        .toInt()]; //get current question based on current page

    Answer answer;
    if (question.type == "MC") {
      answer = Answer(answer: List.of(selectedOptionsList));
    } else {
      answer = Answer(answer: [input]);
    }

    question.answer = answer;
    selectedOptionsList.clear();
    input = "";

    int questionIndex =
        consult.questions.indexWhere((q) => q.question == question.question);
    consult.questions[questionIndex] = question;

    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void previousPage() async {
    await controller.previousPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  bool get canAccessPrevious {
    return progress > 0;
  }

  bool get canAccessNext {
    return selectedOptionsList.length > 0 || canSubmitInputField;
  }

  bool get canSubmitInputField {
    return inputValidator.isValid(input);
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

  void getInput(Question question) {
    input = "";
    if (question.type == "FR" && question.answer != null) {
      input = question.answer.answer.first;
      inputController.text = input;
      inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: inputController.text.length),
      );
    }
  }

  void updateInput(String input) => updateQuestionPageWith(input: input);
  void checkedItemsChanged(List<String> items) =>
      updateQuestionPageWith(selectedOptionsList: items);
  void pageChanged(int idx) {
    progress = (idx / (consult.questions.length));
    Question question = this.consult.questions[this.controller.page.toInt()];
    getInput(question);
    getOptionsList(question);
    notifyListeners(QuestionVMProperties.questionPage);
  }

  void updateQuestionPageWith({
    List<String> optionsList,
    List<String> selectedOptionsList,
    String input,
  }) {
    this.optionsList = optionsList ?? this.optionsList;
    this.input = input ?? this.input;
    this.selectedOptionsList = selectedOptionsList ?? this.selectedOptionsList;
    notifyListeners(QuestionVMProperties.questionPage);
  }
}
