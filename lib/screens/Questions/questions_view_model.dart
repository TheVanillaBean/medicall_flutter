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
  static String get questionFormWidget => 'form_widget';
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

  //Question Page Form Fields (QuestionForm.dart)
  String input;
  List<String> optionsList = [];
  List<String> selectedOptionsList = [];
  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  //Nav buttons
  bool canAccessPrevious = false;
  bool canAccessNext = false;

  QuestionsViewModel({
    @required this.auth,
    @required this.consult,
    this.progress = 0.0,
    this.input = '',
  });

  void nextPage() async {
    disableNavButtons();
    Question question = this.consult.questions[this
        .controller
        .page
        .toInt()]; //get current question based on current page

    Answer answer;
    if (question.type == "MC") {
      answer = Answer(answer: List.of(selectedOptionsList));
    } else {
      inputFocusNode.unfocus();
      answer = Answer(answer: [input]);
    }

    question.answer = answer;

    int questionIndex =
        consult.questions.indexWhere((q) => q.question == question.question);
    consult.questions[questionIndex] = question;

    for (var opt in question.options) {
      if (opt.hasSubQuestions) {
        if (selectedOptionsList.contains(opt.value)) {
          this
              .consult
              .questions
              .insert(questionIndex + 1, opt.subQuestions.first);
          notifyListeners(QuestionVMProperties.questionScreen);
        } else {
          if (this
                  .consult
                  .questions
                  .where((q) => q == opt.subQuestions.first)
                  .length >
              0) {
            this
                .consult
                .questions
                .removeWhere((q) => q == opt.subQuestions.first);
            notifyListeners(QuestionVMProperties.questionScreen);
          }
        }
      }
    }

    await controller.nextPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    updateNavButtonState();
  }

  void previousPage() async {
    disableNavButtons();
    await controller.previousPage(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
    updateNavButtonState();
  }

  void updateQuestionFields(Question question) {
    optionsList.clear();
    selectedOptionsList.clear();
    input = "";

    if (question.type == "MC") {
      for (Option opt in question.options) {
        optionsList.add(opt.value);
      }

      if (question.answer != null) {
        List<String> selectedList = [];
        for (var answer in question.answer.answer) {
          selectedList.add(answer);
        }
        selectedOptionsList = selectedList;
      }
    }

    if (question.type == "FR" && question.answer != null) {
      input = question.answer.answer.first;
      inputController.text = input;
      inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: inputController.text.length),
      );
    }
  }

  void checkForCondition(Question question) {
    if (question.type == "MC") {
      for (Option opt in question.options) {
        if (selectedOptionsList.contains(opt.value) && opt.hasSubQuestions) {}
      }
    }
  }

  void updateInput(String input) => updateQuestionPageWith(input: input);
  void checkedItemsChanged(List<String> items) =>
      updateQuestionPageWith(selectedOptionsList: items);
  void pageChanged(int idx) {
    progress = (idx / (consult.questions.length));
    notifyListeners(QuestionVMProperties.questionProgressBar);
  }

  void updateQuestionPageWith({
    List<String> optionsList,
    List<String> selectedOptionsList,
    String input,
  }) {
    this.optionsList = optionsList ?? this.optionsList;
    this.input = input ?? this.input;
    this.selectedOptionsList = selectedOptionsList ?? this.selectedOptionsList;
    updateNavButtonState();
    notifyListeners(QuestionVMProperties.questionFormWidget);
  }

  void updateNavButtonState() {
    this.canAccessPrevious = progress > 0;
    this.canAccessNext = this.selectedOptionsList.length > 0 ||
        inputValidator.isValid(this.input);
    notifyListeners(QuestionVMProperties.questionNavButtons);
  }

  void disableNavButtons() {
    this.canAccessPrevious = false;
    this.canAccessNext = false;
    notifyListeners(QuestionVMProperties.questionNavButtons);
  }
}
