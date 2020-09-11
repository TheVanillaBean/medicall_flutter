import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/questionnaire/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/progress_bar.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/question_page.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/questions_view_model.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/review_questions/review_page.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  final QuestionsViewModel model;

  static Widget create(
    BuildContext context,
    bool displayMedHistory,
    Consult consult,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final FirebaseStorageService firebaseStorageService =
        Provider.of<FirebaseStorageService>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return PropertyChangeProvider(
      value: QuestionsViewModel(
        auth: auth,
        consult: consult,
        database: database,
        storageService: firebaseStorageService,
        displayMedHistory: displayMedHistory,
        userProvider: userProvider,
      ),
      child: PropertyChangeConsumer<QuestionsViewModel>(
        properties: [QuestionVMProperties.questionScreen],
        builder: (_, model, __) => QuestionsScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    @required BuildContext context,
    @required Consult consult,
    @required bool displayMedHistory,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.questions,
      arguments: {
        'consult': consult,
        'displayMedHistory': displayMedHistory,
      },
    );
  }

  QuestionsScreen({
    @required this.model,
  });

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen>
    with QuestionnaireStatusUpdate {
  QuestionsViewModel get model => widget.model;

  @override
  void dispose() {
    widget.model.inputController.dispose();
    widget.model.inputFocusNode.dispose();
    widget.model.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);
    model.setQuestionnaireStatusListener(this);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        theme: Theme.of(context),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () async {
            String cancelText = "";
            String cancelTitle = "";
            if (this.model.displayMedHistory) {
              cancelTitle = "Don't Update?";
              cancelText =
                  "Are you sure you don't want to update your medical history?";
            } else {
              cancelTitle = "Cancel Visit?";
              cancelText = "Are you sure you want to cancel this visit?";
            }
            final didPressYes = await PlatformAlertDialog(
              title: cancelTitle,
              content: cancelText,
              defaultActionText: "Yes, cancel",
              cancelActionText: "No",
            ).show(context);
            if (didPressYes) {
              TempUserProvider tempUserProvider = Provider.of<TempUserProvider>(
                context,
                listen: false,
              );
              if (tempUserProvider.consult != null) {
                tempUserProvider.consult = null;
                PatientDashboardScreen.show(
                  context: context,
                  pushReplaceNamed: true,
                );
              } else {
                Navigator.of(context).popUntil(
                  (ModalRoute.withName(Routes.providerDetail)),
                );
              }
            }
          },
        ),
      ),
      body: KeyboardDismisser(
        child: FutureBuilder<List<ScreeningQuestions>>(
            future: model.displayMedHistory
                ? db.getScreeningQuestions(
                    symptomName: "General Medical History")
                : db.getScreeningQuestions(
                    symptomName: this.model.consult.symptom),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "An error has occurred loading this questionnaire. Please contact customer support.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                this.model.consult.questions =
                    snapshot.data.first.screeningQuestions;
                if (this.model.consult.symptom.length == 0) {
                  // if symptom name is "", then the user is updating their medical history from the account screen, and does not need the first question asking if they have seen this provider before.
                  this.model.consult.questions.removeAt(0);
                }
                return QuestionsPageView();
              }
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }),
      ),
    );
  }

  @override
  void updateStatus(String msg) {
    AppUtil().showFlushBar(msg, context);
  }
}

class QuestionsPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionPageView],
    ).value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 9,
          child: PageView.builder(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: model.controller,
            onPageChanged: model.pageChanged,
            itemBuilder: (BuildContext context, int idx) {
              if (idx != model.pageIndex) {
                return Container();
              } else if (idx == model.consult.questions.length) {
                return ReviewPage();
              } else {
                return QuestionPage(
                  questionIndex: model.pageIndex,
                );
              }
            },
          ),
        ),
        if (model.submitted)
          Expanded(
            flex: 2,
            child: Container(
              height: 30,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        if (!model.submitted &&
            model.pageIndex != model.consult.questions.length)
          Expanded(
            flex: 2,
            child: NavigationButtons(),
          ),
      ],
    );
  }
}

class NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionNavButtons],
    ).value;
    return model.progress < 1.0 ? _buildNavigationButtons(model) : Container();
  }

  Widget _buildNavigationButtons(QuestionsViewModel model) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Align(
            alignment: FractionalOffset.center,
            child: IconButton(
                iconSize: 80,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 40,
                ),
                disabledColor: Colors.black12,
                onPressed: model.canAccessPrevious
                    ? () => model.previousPage()
                    : null),
          ),
        ),
        Expanded(
            flex: 4,
            child: Align(
                alignment: Alignment.center, child: AnimatedProgressbar())),
        Expanded(
          flex: 1,
          child: Align(
            alignment: FractionalOffset.center,
            child: IconButton(
                iconSize: 80,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 40,
                ),
                disabledColor: Colors.black12,
                onPressed: model.canAccessNext ? () => model.nextPage() : null),
          ),
        ),
      ],
    );
  }
}
