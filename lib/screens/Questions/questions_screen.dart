import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
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
            return StartPage(symptom: this.symptom);
          } else if (idx == this.symptom.screeningQuestions.length + 1) {
            return CongratsPage(symptom: this.symptom);
          } else {
            return QuestionPage(
                question: this.symptom.screeningQuestions[idx - 1]);
          }
        },
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  final Symptom symptom;
  final PageController controller;
  StartPage({this.symptom, this.controller});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuestionsViewModel>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(symptom.name, style: Theme.of(context).textTheme.headline),
          Divider(),
          Expanded(child: Text(symptom.description)),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                onPressed: state.nextPage,
                label: Text('Start Questionaire!'),
                icon: Icon(Icons.poll),
                color: Colors.green,
              )
            ],
          )
        ],
      ),
    );
  }
}

class CongratsPage extends StatelessWidget {
  final Symptom symptom;
  CongratsPage({this.symptom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Congrats! You completed the ${symptom.name} quiz',
            textAlign: TextAlign.center,
          ),
          Divider(),
          Image.asset('assets/congrats.gif'),
          Divider(),
          FlatButton.icon(
            color: Colors.green,
            icon: Icon(Icons.check),
            label: Text(' Mark Complete!'),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/topics',
                (route) => false,
              );
            },
          )
        ],
      ),
    );
  }
}

class QuestionPage extends StatelessWidget {
  final Question question;
  QuestionPage({this.question});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuestionsViewModel>(context, listen: false);

    if (question.type == "FR") {
      state.nextPage();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(question.question),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options.map((opt) {
              return Container(
                height: 90,
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.black26,
                child: InkWell(
                  onTap: () {
                    state.selected = opt;
                    state.nextPage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                            state.selected == opt ? Icons.create : Icons.cached,
                            size: 30),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text(
                              opt.value,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
