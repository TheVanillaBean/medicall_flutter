import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/screens/Questions/question_page_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class QuestionsViewModel with OptionInputValidator, ChangeNotifier {
  final AuthBase auth;
  final Consult consult;
  final PageController controller = PageController();

  QuestionPageViewModel questionPageViewModel;

  double progress;

  QuestionsViewModel({
    @required this.auth,
    @required this.consult,
    this.progress = 0.0,
  });

  Future<void> createConsult() {
    print(consult);
  }

  void nextPage() async {
    Question question = questionPageViewModel.question;
    Answer answer;
    if (question.type == "MC") {
      answer =
          Answer(answer: List.of(questionPageViewModel.selectedOptionsList));
    } else {
      answer = Answer(answer: [questionPageViewModel.input]);
    }

    question.answer = answer;
    questionPageViewModel.selectedOptionsList.clear();
    questionPageViewModel.input = "";

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
    return questionPageViewModel.selectedOptionsList.length > 0 ||
        questionPageViewModel.canSubmitInputField;
  }

  void pageChanged(int idx) =>
      updateWith(progress: (idx / (consult.questions.length)));

  void updateWith({
    double progress,
    bool submitted,
  }) {
    this.progress = progress ?? this.progress;
    notifyListeners();
  }
}
