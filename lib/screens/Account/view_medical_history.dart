import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/questionnaire/question_model.dart';
import 'package:Medicall/models/questionnaire/screening_questions_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/screening_question_list_item.dart';
import 'package:Medicall/screens/Questions/questions_screen.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewMedicalHistory extends StatelessWidget {
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.viewMedicalHistory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Visit Information",
        theme: Theme.of(context),
      ),
      body: FutureBuilder<ScreeningQuestions>(
        future: db.medicalHistory(uid: userProvider.user.uid),
        builder:
            (BuildContext context, AsyncSnapshot<ScreeningQuestions> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      'MEDICAL HISTORY QUESTIONS',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListItemsBuilder<Question>(
                      scrollable: false,
                      snapshot: null,
                      itemsList: snapshot.data != null
                          ? snapshot.data.screeningQuestions
                              .where(
                                  (question) => question.type != Q_TYPE.PHOTO)
                              .toList()
                          : [],
                      emptyContentWidget: EmptyContent(
                        title: "Not filled out",
                        message:
                            "You have not entered your medical history with us",
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
                    text: "Update Medical History",
                    trailingIcon: Icons.chevron_right,
                    onPressed: () {
                      return QuestionsScreen.show(
                          context: context,
                          consult: Consult(providerId: "", symptom: ""),
                          displayMedHistory: true);
                    },
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
