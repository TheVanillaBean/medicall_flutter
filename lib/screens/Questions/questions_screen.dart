import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/Questions/progress_bar.dart';
import 'package:Medicall/screens/Questions/question_page.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatelessWidget {
  final QuestionsViewModel model;

  static Widget create(
    BuildContext context,
    Consult consult,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return PropertyChangeProvider(
      value: QuestionsViewModel(
        auth: auth,
        consult: consult,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedProgressbar(value: model.progress),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: this.model.controller,
              onPageChanged: this.model.pageChanged,
              itemBuilder: (BuildContext context, int idx) {
                if (idx == this.model.consult.questions.length) {
                  return reviewPage(context);
                } else {
                  model.getOptionsList(this.model.consult.questions[idx]);
                  model.getInput(this.model.consult.questions[idx]);
                  return QuestionPage(
                    question: this.model.consult.questions[idx],
                  );
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: NavigationButtons(),
          ),
        ],
      ),
    );
  }

  Widget reviewPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Congratulations! ',
            textAlign: TextAlign.center,
          ),
          Divider(),
          FlatButton.icon(
            color: Colors.blueAccent,
            icon: Icon(Icons.check),
            label: Text('Complete consultation'),
            onPressed: () {
              DashboardScreen.show(context: context, pushReplaceNamed: true);
            },
          )
        ],
      ),
    );
  }
}

class NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionPage],
    ).value;
    return _buildNavigationButtons(model);
  }

  Widget _buildNavigationButtons(QuestionsViewModel model) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: CustomRaisedButton(
            color: Colors.blue,
            borderRadius: 24,
            child: Text(
              "Previous",
              style: TextStyle(color: Colors.white),
            ),
            onPressed:
                model.canAccessPrevious ? () => model.previousPage() : null,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 1,
          child: CustomRaisedButton(
            color: Colors.blue,
            borderRadius: 24,
            child: Text(
              "Next",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: model.canAccessNext ? () => model.nextPage() : null,
          ),
        ),
      ],
    );
  }
}
