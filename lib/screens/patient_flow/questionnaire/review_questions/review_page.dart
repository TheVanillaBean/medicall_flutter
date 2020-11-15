import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/questionnaire/question_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/screens/patient_flow/drivers_license/photo_id.dart';
import 'package:Medicall/screens/patient_flow/personal_info/personal_info.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/questions_screen.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/questions_view_model.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/review_questions/review_page_list_item.dart';
import 'package:Medicall/screens/patient_flow/visit_payment/make_payment.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
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
      /** the following conditionals are basically saying:
       * If user has not submitted photo ID - take them to photo ID screen
       * If user has submitted photo ID, but has not submitted personal info,
       * take them to personal info screen
       * If user has submitted photo ID and personal info, take them straight
       * to MakePayment screen.
       *
       * The user only needs to submit photo ID and personal info once.
       * They have to make a payment every time though.
      */
      if ((model.userProvider.user as PatientUser).photoID.length > 0) {
        //photo ID check
        if ((model.userProvider.user as PatientUser).fullName.length > 2 &&
            (model.userProvider.user as PatientUser).profilePic.length > 2 &&
            (model.userProvider.user as PatientUser).mailingAddress.length >
                2) {
          //personal info check
          MakePayment.show(context: context, consult: model.consult);
        } else {
          PersonalInfoScreen.show(context: context, consult: model.consult);
        }
      } else {
        PhotoIDScreen.show(
            context: context, pushReplaceNamed: true, consult: model.consult);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionNavButtons],
    ).value;
    ScrollController scrollController = ScrollController();
    String title = model.displayMedHistory
        ? "Please review your medical history:"
        : "Please review your consult:";

    String completeBtnText =
        model.displayMedHistory ? "Save & Continue" : "Complete Consult";

    return Scaffold(
        body: Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white.withAlpha(170),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: SizedBox(
              height: 60,
              width: ScreenUtil.screenWidthDp - 60,
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
          ),
        ),
      ],
    ));
  }
}
