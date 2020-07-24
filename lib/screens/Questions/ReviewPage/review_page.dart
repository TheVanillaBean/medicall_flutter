import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/screens/PersonalInfo/personal_info.dart';
import 'package:Medicall/screens/Questions/ReviewPage/review_page_list_item.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class ReviewPage extends StatelessWidget {
  Future<void> completeConsultBtnPressed(
      BuildContext context, QuestionsViewModel model) async {
    await model.saveConsultation();
    PersonalInfoScreen.show(context: context, consult: model.consult);
  }

  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionNavButtons],
    ).value;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please review your consult:',
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
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomRaisedButton(
                      color: Colors.blue,
                      borderRadius: 14,
                      child: Text(
                        "Previous",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto Medium',
                          fontSize: 14,
                        ),
                      ),
                      onPressed:
                          !model.submitted ? () => model.previousPage() : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomRaisedButton(
                      color: Colors.blue,
                      borderRadius: 14,
                      child: Text(
                        'Complete consult',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto Medium',
                          fontSize: 14,
                        ),
                      ),
                      onPressed: !model.submitted
                          ? () => completeConsultBtnPressed(context, model)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
