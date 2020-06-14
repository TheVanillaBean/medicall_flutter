import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class QuestionsViewModel with OptionInputValidator, ChangeNotifier {
  final AuthBase auth;
  final Consult consult;
  final PageController controller = PageController();

  double progress;
  Option selected;

  QuestionsViewModel({
    @required this.auth,
    @required this.consult,
    this.progress = 0.0,
  });

  void nextPage(Question question) async {
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

  bool canAccessNext(
    List<String> selectedOptionsList,
    bool canSubmitInputField,
  ) {
    return selectedOptionsList.length > 0 || canSubmitInputField;
  }

  void pageChanged(int idx) =>
      updateWith(progress: (idx / (consult.questions.length)));

  void updateWith({
    double progress,
    Option selected,
    bool submitted,
  }) {
    this.progress = progress ?? this.progress;
    this.selected = selected ?? this.selected;
    notifyListeners();
  }
}
