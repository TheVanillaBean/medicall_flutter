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
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    ScreenUtil.init(context);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Visit Information",
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  PatientDashboardScreen.show(
                    context: context,
                    pushReplaceNamed: true,
                  );
                })
          ]),
      body: FutureBuilder<ScreeningQuestions>(
        future: db.consultQuestionnaire(consultId: consult.uid),
        builder:
            (BuildContext context, AsyncSnapshot<ScreeningQuestions> snapshot) {
          return Container(
            height: ScreenUtil.screenHeightDp - ScreenUtil.statusBarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
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
                              scrollable: false,
                              snapshot: null,
                              itemsList: snapshot.data != null
                                  ? snapshot.data.screeningQuestions
                                      .where((question) =>
                                          question.type != Q_TYPE.PHOTO)
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
                        ],
                      ),
                    )),
                Container(
                  height: 85,
                  color: Colors.transparent,
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Card(
                    elevation: 3,
                    shadowColor: Colors.grey.withAlpha(120),
                    borderOnForeground: false,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      dense: true,
                      leading: Icon(
                        Icons.photo_album,
                        size: 25,
                        color: Colors.grey,
                      ),
                      title: Text(
                        "VIEW PHOTOS",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => {
                        ConsultPhotos.show(
                          context: context,
                          consult: consult,
                        )
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
