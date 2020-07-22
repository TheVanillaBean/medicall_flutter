import 'package:Medicall/models/question_model.dart';
import 'package:flutter/material.dart';

class ReviewPageListItem extends StatelessWidget {
  const ReviewPageListItem({@required this.question});
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 2,
        ),
        dense: true,
        title: Text(
          question.question,
          style: TextStyle(
            fontFamily: 'Roboto Regular',
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            question.answer.answer.first,
            style: TextStyle(
              fontFamily: 'Roboto Regular',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ),
        trailing: Icon(Icons.check),
      ),
    );
  }
}
