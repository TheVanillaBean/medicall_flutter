import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info.dart';
import 'package:Medicall/screens/Questions/ReviewPage/review_page_list_item.dart';
import 'package:Medicall/screens/Questions/questions_screen.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class ReviewPage extends StatelessWidget {
  Future<void> completeBtnPressed(
      BuildContext context, QuestionsViewModel model) async {
    if (model.displayMedHistory) {
      await model.saveMedicalHistory();
      if (model.consult.symptom.length == 0) {
        Navigator.of(context).pop();
      } else {
        QuestionsScreen.show(
            context: context, consult: model.consult, displayMedHistory: false);
      }
    } else {
      await model.saveConsultation();
      PersonalInfoScreen.show(context: context, consult: model.consult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionNavButtons],
    ).value;

    String title = model.displayMedHistory
        ? "Please review your medical history:"
        : "Please review your consult:";

    String completeBtnText =
        model.displayMedHistory ? "Save medical history" : "Complete Consult";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto Regular',
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: ListItemsBuilder<Question>(
                scrollable: false,
                snapshot: null,
                itemsList: model.consult.questions
                    .where((question) => question.type != Q_TYPE.PHOTO)
                    .toList(),
                itemBuilder: (context, question) => ReviewPageListItem(
                  question: question,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: ReusableRaisedButton(
                        title: 'Previous',
                        onPressed: !model.submitted
                            ? () => model.previousPage()
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: ReusableRaisedButton(
                        title: completeBtnText,
                        onPressed: !model.submitted
                            ? () => completeBtnPressed(context, model)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
