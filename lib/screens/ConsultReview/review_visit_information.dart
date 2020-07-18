import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/screening_question_list_item.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewVisitInformation extends StatelessWidget {
  final Consult consult;

  const ReviewVisitInformation({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitInformation,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text("Visit Information"),
      ),
      body: FutureBuilder<ScreeningQuestions>(
        future: db.consultQuestionnaire(consultId: consult.uid),
        builder:
            (BuildContext context, AsyncSnapshot<ScreeningQuestions> snapshot) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'SCREENING QUESTIONS',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListItemsBuilder<Question>(
                  snapshot: null,
                  itemsList: snapshot.data != null
                      ? snapshot.data.screeningQuestions
                          .where((question) => question.type != Q_TYPE.PHOTO)
                          .toList()
                      : [],
                  itemBuilder: (context, question) => ScreeningQuestionListItem(
                    question: question,
                    onTap: null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              CustomFlatButton(
                text: "VIEW PHOTOS",
                trailingIcon: Icons.chevron_right,
                onPressed: () => {},
              )
            ],
          );
        },
      ),
    );
  }
}
