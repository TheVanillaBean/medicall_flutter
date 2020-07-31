import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/consult_photos.dart';
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
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Visit Information",
        context: context,
      ),
      body: FutureBuilder<ScreeningQuestions>(
        future: db.consultQuestionnaire(consultId: consult.uid),
        builder:
            (BuildContext context, AsyncSnapshot<ScreeningQuestions> snapshot) {
          return SingleChildScrollView(
            child: Column(
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
                    emptyContentWidget: EmptyContent(
                      title: "No Questions",
                      message: "An error likely occurred.",
                    ),
                    itemBuilder: (context, question) =>
                        ScreeningQuestionListItem(
                      question: question,
                      onTap: null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                CustomFlatButton(
                  text: "VIEW PHOTOS",
                  trailingIcon: Icons.chevron_right,
                  onPressed: () => {
                    ConsultPhotos.show(
                      context: context,
                      consult: consult,
                    )
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
