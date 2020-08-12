import 'dart:async';

import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/option_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

// Properties
abstract class QuestionVMProperties {
  static String get questionDots => 'dots_indicator';
  static String get questionFormWidget => 'form_widget';
  static String get questionProgressBar => 'progress_bar';
  static String get questionNavButtons => 'nav_buttons';
  static String get questionPage => 'page';
  static String get questionPageView => 'question_page_view';
  static String get questionScreen => 'root_screen'; //i.e root
}

class QuestionsViewModel extends PropertyChangeNotifier
    with OptionInputValidator {
  final UserProvider userProvider;
  final AuthBase auth;
  final FirestoreDatabase database;
  final FirebaseStorageService storageService;
  final Consult consult;
  final PageController controller = PageController(initialPage: 0);
  double progress;
  int pageIndex = 0;
  bool displayMedHistory = false;

  //Question Page Form Fields (question_form.dart)
  String input;
  List<String> optionsList = [];
  List<String> selectedOptionsList = [];
  List<Map<String, ByteData>> questionPhotos = [];
  String questionPlaceholderURL = "";
  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();
  double imageIndex = 0;

  //Nav buttons
  bool canAccessPrevious = false;
  bool canAccessNext = false;

  bool submitted = false;

  QuestionnaireStatusUpdate questionnaireStatusUpdate;

  QuestionsViewModel({
    @required this.auth,
    @required this.consult,
    @required this.database,
    @required this.storageService,
    @required this.displayMedHistory,
    @required this.userProvider,
    this.progress = 0.0,
    this.input = '',
  });

  void setQuestionnaireStatusListener(
      QuestionnaireStatusUpdate questionnaireStatusUpdate) {
    this.questionnaireStatusUpdate = questionnaireStatusUpdate;
  }

  Future<void> saveMedicalHistory() async {
    disableNavButtons();
    this.submitted = true;
    notifyListeners(QuestionVMProperties.questionPageView);
    ScreeningQuestions questions =
        ScreeningQuestions(screeningQuestions: consult.questions);
    String uid = (await this.auth.currentUser()).uid;
    await database.saveMedicalHistory(
      userId: uid,
      screeningQuestions: questions,
    );
    this.displayMedHistory = false;
    User user = await auth.currentUser();
    (user as PatientUser).hasMedicalHistory = true;
    this.database.setUser(user);
    this.userProvider.user = user;
    this.submitted = false;
  }

  Future<void> saveConsultation() async {
    disableNavButtons();
    this.submitted = true;
    notifyListeners(QuestionVMProperties.questionPageView);
    consult.patientId = (await this.auth.currentUser()).uid;
    consult.state = ConsultStatus.PendingPayment;
    ScreeningQuestions questions =
        ScreeningQuestions(screeningQuestions: consult.questions);
    String consultId = await database.saveConsult(consult: consult);
    questionnaireStatusUpdate.updateStatus(
        "Securely saving visit information. This may take several seconds...");
    await saveConsultPhotos(consultId, questions);
    await database.saveQuestionnaire(
        consultId: consultId, screeningQuestions: questions);
    consult.uid = consultId;
  }

  Future<void> saveConsultPhotos(
      String consultId, ScreeningQuestions questions) async {
    for (Question question in questions.screeningQuestions) {
      if (question.type == Q_TYPE.PHOTO) {
        question.answer.answer = [];
        for (Map<String, ByteData> byteDataMap in question.answer.images) {
          String downloadURL = await storageService.uploadConsultPhoto(
            consultId: consultId,
            byteData: byteDataMap.values.first,
            name: FirebaseStorageService.getImageName(byteDataMap.keys.first),
          );
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
    if (question.type == Q_TYPE.MC || question.type == Q_TYPE.SC) {
      answer = Answer(answer: List.of(selectedOptionsList));
    } else if (question.type == Q_TYPE.FR) {
      inputFocusNode.unfocus();
      answer = Answer(answer: [input]);
    } else {
      answer = Answer(images: List.of(this.questionPhotos));
    }

    question.answer = answer;

    int questionIndex =
        consult.questions.indexWhere((q) => q.question == question.question);
    consult.questions[questionIndex] = question;

    if (question.type == Q_TYPE.MC || question.type == Q_TYPE.SC) {
      for (Option opt in question.options) {
        if (opt.hasSubQuestions) {
          if (selectedOptionsList.contains(opt.value)) {
            opt.subQuestions.forEach((subQuestion) {
              if (!this.consult.questions.contains(subQuestion)) {
                this.consult.questions.insert(questionIndex + 1, subQuestion);
              }
            });
          } else {
            removeSubQuestionsIfAny(opt);
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

  void removeSubQuestionsIfAny(Option opt) {
    if (opt.hasSubQuestions) {
      opt.subQuestions.forEach((question) {
        this.consult.questions.removeWhere((q) => q == question);
        if (question.type == Q_TYPE.MC || question.type == Q_TYPE.MC) {
          question.options.forEach((option) {
            removeSubQuestionsIfAny(option);
          });
        }
      });
    }
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

    if (question.type == Q_TYPE.MC || question.type == Q_TYPE.SC) {
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

    if (question.type == Q_TYPE.FR) {
      if (question.answer != null) {
        input = question.answer.answer.first;
      }
      inputController.text = input;
      inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: inputController.text.length),
      );
    }

    if (question.type == Q_TYPE.PHOTO) {
      this.questionPlaceholderURL = question.placeholderImage;
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
    pageIndex = idx;
    notifyListeners(QuestionVMProperties.questionPageView);
    progress = (idx / (consult.questions.length));
    notifyListeners(QuestionVMProperties.questionProgressBar);
  }

  void updateQuestionPageWith({
    List<String> optionsList,
    List<String> selectedOptionsList,
    String input,
    List<Map<String, ByteData>> questionPhotos,
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
    this.canAccessNext = determineIfCanAccessNext();
    notifyListeners(QuestionVMProperties.questionNavButtons);
  }

  bool determineIfCanAccessNext() {
    if (pageIndex == consult.questions.length) {
      return true;
    }
    if (this.consult.questions[pageIndex].required) {
      if (this.consult.questions[pageIndex].type == Q_TYPE.MC ||
          this.consult.questions[pageIndex].type == Q_TYPE.SC) {
        return this.selectedOptionsList.length > 0;
      } else if (this.consult.questions[pageIndex].type == Q_TYPE.FR) {
        return inputValidator.isValid(this.input);
      } else {
        return this.questionPhotos.length > 0;
      }
    } else {
      return true;
    }
  }

  void disableNavButtons() {
    this.canAccessPrevious = false;
    this.canAccessNext = false;
    notifyListeners(QuestionVMProperties.questionNavButtons);
  }

  void updateDotsIndicator(double index) {
    this.imageIndex = index;
    notifyListeners(QuestionVMProperties.questionDots);
  }
}

mixin QuestionnaireStatusUpdate {
  void updateStatus(String msg);
}
