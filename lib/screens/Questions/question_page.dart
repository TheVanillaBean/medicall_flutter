import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/Questions/question_form.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
    ScrollController scrollController = ScrollController();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Scrollbar(
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Text(
                        question.question,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      if (question.maxImages > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                              "Select up to ${question.maxImages} images."),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Flexible(
            child: QuestionForm.create(
              context,
              question,
              model,
            ),
          ),
        ],
      ),
    );
  }
}
