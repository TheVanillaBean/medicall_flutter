import 'package:Medicall/models/questionnaire/question_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreeningQuestionListItem extends StatelessWidget {
  const ScreeningQuestionListItem({
    @required this.question,
    this.onTap,
  });
  final Question question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        question.question,
        style: Theme.of(context).textTheme.caption,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (String answer in question.answer.answer)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                answer,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
