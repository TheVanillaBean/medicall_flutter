import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/Questions/option_list_item.dart';
import 'package:Medicall/screens/Questions/progress_bar.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatelessWidget {
  final QuestionsViewModel model;
  final Symptom symptom;
  final Consult consult;

  static Widget create(
    BuildContext context,
    Symptom symptom,
    Consult consult,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<QuestionsViewModel>(
      create: (context) => QuestionsViewModel(
        auth: auth,
      ),
      child: Consumer<QuestionsViewModel>(
        builder: (_, model, __) => QuestionsScreen(
          symptom: symptom,
          consult: consult,
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    @required BuildContext context,
    @required Symptom symptom,
    @required Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.questions,
      arguments: {
        'symptom': symptom,
        'consult': consult,
      },
    );
  }

  QuestionsScreen({
    @required this.model,
    @required this.symptom,
    @required this.consult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedProgressbar(value: model.progress),
        leading: IconButton(
          icon: Icon(Icons.timer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: model.controller,
        onPageChanged: (int idx) => model.progress =
            (idx / (this.symptom.screeningQuestions.length + 1)),
        itemBuilder: (BuildContext context, int idx) {
          if (idx == 0) {
            return startPage(context);
          } else if (idx == this.symptom.screeningQuestions.length + 1) {
            return reviewPage(context);
          } else {
            return questionPage(
              context,
              this.symptom.screeningQuestions[idx - 1],
            );
          }
        },
      ),
    );
  }

  Widget startPage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(symptom.name, style: Theme.of(context).textTheme.headline5),
          Divider(),
          Expanded(child: Text(symptom.description)),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                onPressed: model.nextPage,
                label: Text('Start Questionnaire!'),
                icon: Icon(Icons.poll),
                color: Colors.green,
              )
            ],
          )
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
            'Congratulations! You have completed this consult. Your provider will respond back within 24 hours.',
            textAlign: TextAlign.center,
          ),
          Divider(),
          FlatButton.icon(
            color: Colors.green,
            icon: Icon(Icons.check),
            label: Text('Continue to your dashboard'),
            onPressed: () {
              DashboardScreen.show(context: context, pushReplaceNamed: true);
            },
          )
        ],
      ),
    );
  }

  Widget questionPage(BuildContext context, Question question) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.topCenter,
              child: Text(question.question),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: _buildOptions(question, context),
          )
        ],
      ),
    );
  }

  Widget _buildOptions(Question question, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: question.options.map((opt) {
        return OptionListItem.create(
          context: context,
          type: question.type,
          option: opt,
          onTap: () {},
          onInput: () {},
        );
      }).toList(),
    );
  }
}
