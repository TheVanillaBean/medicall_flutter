import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/Questions/question_form.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class QuestionPage extends StatelessWidget {
  final int questionIndex;

  const QuestionPage({@required this.questionIndex});

  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionPage],
    ).value;
    final Question question = model.consult.questions[questionIndex];
    model.updateQuestionFields(question);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            fit: FlexFit.loose,
            flex: 2,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
              alignment: Alignment.topCenter,
              child: Column(
                children: <Widget>[
                  Text(question.question),
                  if (question.maxImages > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text("Select up to ${question.maxImages} images."),
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            flex: 8,
            child: Container(
              padding: EdgeInsets.all(20),
              child: QuestionForm.create(
                context,
                question,
                model,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
