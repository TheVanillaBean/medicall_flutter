import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/Questions/progress_bar.dart';
import 'package:Medicall/screens/Questions/question_page.dart';
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
        symptom: symptom,
        consult: consult,
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
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: model.controller,
        itemCount: this.consult.questions.length + 1,
        onPageChanged: this.model.pageChanged,
        itemBuilder: (BuildContext context, int idx) {
          if (idx == this.consult.questions.length) {
            return reviewPage(context);
          } else {
            return QuestionPage.create(
              context,
              this.consult.questions[idx],
            );
          }
        },
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
}
