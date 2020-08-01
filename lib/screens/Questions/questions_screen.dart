import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Questions/ReviewPage/review_page.dart';
import 'package:Medicall/screens/Questions/progress_bar.dart';
import 'package:Medicall/screens/Questions/question_page.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/firebase_storage_service.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatefulWidget {
  final QuestionsViewModel model;

  static Widget create(
    BuildContext context,
    Consult consult,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final FirebaseStorageService firebaseStorageService =
        Provider.of<FirebaseStorageService>(context, listen: false);
    return PropertyChangeProvider(
      value: QuestionsViewModel(
          auth: auth,
          consult: consult,
          database: database,
          storageService: firebaseStorageService),
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
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.questions,
      arguments: {
        'consult': consult,
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
    NonAuthDatabase db = Provider.of<NonAuthDatabase>(context, listen: false);
    model.setQuestionnaireStatusListener(this);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        theme: Theme.of(context),
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pushNamed('/dashboard');
            }),
      ),
      body: FutureBuilder<List<ScreeningQuestions>>(
          future:
              db.getScreeningQuestions(symptomName: this.model.consult.symptom),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              this.model.consult.questions =
                  snapshot.data.first.screeningQuestions;
              return QuestionsPageView();
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
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
          flex: 8,
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
        if (!model.submitted)
          Expanded(
            flex: 1,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed:
                      model.canAccessNext ? () => model.previousPage() : null),
            ),
          ),
          Expanded(
              flex: 5,
              child: Align(
                  alignment: Alignment.center, child: AnimatedProgressbar())),
          Expanded(
            flex: 1,
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed:
                      model.canAccessNext ? () => model.nextPage() : null),
            ),
          ),
        ],
      ),
    );
  }
}
