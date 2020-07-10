import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

// Properties
abstract class QuestionVMProperties {
  static String get questionFormWidget => 'form_widget';
  static String get questionProgressBar => 'progress_bar';
  static String get questionNavButtons => 'nav_buttons';
  static String get questionPage => 'page';
  static String get questionPageView => 'question_page_view';
  static String get questionScreen => 'root_screen'; //i.e root
}

class QuestionsViewModel extends PropertyChangeNotifier
    with OptionInputValidator {
  final AuthBase auth;
  final FirestoreDatabase database;
  final FirebaseStorageService storageService;
  final Consult consult;
  final PageController controller = PageController();
  double progress;

  //Question Page Form Fields (question_form.dart)
  String input;
  List<String> optionsList = [];
  List<String> selectedOptionsList = [];
  List<Asset> questionPhotos = [];
  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  //Nav buttons
  bool canAccessPrevious = false;
  bool canAccessNext = false;

  bool submitted = false;

  QuestionsViewModel({
    @required this.auth,
    @required this.consult,
    @required this.database,
    @required this.storageService,
    this.progress = 0.0,
    this.input = '',
  });

  Future<void> saveConsultation() async {
    disableNavButtons();
    this.submitted = true;
    notifyListeners(QuestionVMProperties.questionPage);
    consult.patientId = (await this.auth.currentUser()).uid;
    consult.state = "New";
    ScreeningQuestions questions =
        ScreeningQuestions(screeningQuestions: consult.questions);
    String consultId = await database.saveConsult(consult: consult);
    await saveConsultPhotos(consultId, questions);
    await database.saveQuestionnaire(
        consultId: consultId, screeningQuestions: questions);
  }

  Future<void> saveConsultPhotos(
      String consultId, ScreeningQuestions questions) async {
    for (Question question in questions.screeningQuestions) {
      if (question.type == "photo") {
        question.answer.answer = [];
        for (Asset imageAsset in question.answer.images) {
          String downloadURL = await storageService.uploadConsultPhoto(
              consultId: consultId, asset: imageAsset);
          question.answer.answer.add(downloadURL);
        }
      }
    }
  }

  void nextPage() async {
    disableNavButtons();
    Question question = this.consult.questions[this
        .controller
        .page
        .toInt()]; //get current question based on current page

    Answer answer;
    if (question.type == "MC") {
      answer = Answer(answer: List.of(selectedOptionsList));
    } else if (question.type == "FR") {
      inputFocusNode.unfocus();
      answer = Answer(answer: [input]);
    } else {
      answer = Answer(images: List.of(this.questionPhotos));
    }

    question.answer = answer;

    int questionIndex =
        consult.questions.indexWhere((q) => q.question == question.question);
    consult.questions[questionIndex] = question;

    if (question.type == "MC") {
      for (Option opt in question.options) {
        if (opt.hasSubQuestions) {
          if (selectedOptionsList.contains(opt.value)) {
            if (!this.consult.questions.contains(opt.subQuestions.first)) {
              this
                  .consult
                  .questions
                  .insert(questionIndex + 1, opt.subQuestions.first);
              notifyListeners(QuestionVMProperties.questionPageView);
            }
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
              notifyListeners(QuestionVMProperties.questionPageView);
            }
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

    if (question.type == "FR") {
      if (question.answer != null) {
        input = question.answer.answer.first;
      }
      inputController.text = input;
      inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: inputController.text.length),
      );
    }

    if (question.type == "photo") {
      if (question.answer != null && question.answer.images.length > 0) {
        this.questionPhotos = question.answer.images;
      } else {
        this.questionPhotos.clear();
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
    List<Asset> questionPhotos,
  }) {
    this.optionsList = optionsList ?? this.optionsList;
    this.input = input ?? this.input;
    this.selectedOptionsList = selectedOptionsList ?? this.selectedOptionsList;
    this.questionPhotos = questionPhotos ?? this.questionPhotos;
    updateNavButtonState();
    notifyListeners(QuestionVMProperties.questionFormWidget);
  }

  void updateNavButtonState() {
    this.canAccessPrevious = progress > 0;
    this.canAccessNext = this.selectedOptionsList.length > 0 ||
        inputValidator.isValid(this.input) ||
        this.questionPhotos.length > 0;
    notifyListeners(QuestionVMProperties.questionNavButtons);
  }

  void disableNavButtons() {
    this.canAccessPrevious = false;
    this.canAccessNext = false;
    notifyListeners(QuestionVMProperties.questionNavButtons);
  }
}
