import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/common_widgets/reusable_card.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/question_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/consult_photos.dart';
import 'package:Medicall/screens/ConsultReview/review_medical_history.dart';
import 'package:Medicall/screens/ConsultReview/screening_question_list_item.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    ScreenUtil.init(context);
    ScrollController scrollController = ScrollController();
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
                  if (userProvider.user.type == USER_TYPE.PATIENT) {
                    PatientDashboardScreen.show(
                      context: context,
                      pushReplaceNamed: true,
                    );
                  } else {
                    ProviderDashboardScreen.show(
                      context: context,
                      pushReplaceNamed: true,
                    );
                  }
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
                  child: Scrollbar(
                    child: FadingEdgeScrollView.fromSingleChildScrollView(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 85,
                  color: Colors.transparent,
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: ReusableCard(
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          title: Text(
                            "PHOTOS",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          onTap: () => {
                            ConsultPhotos.show(
                              context: context,
                              consult: consult,
                            )
                          },
                        ),
                      ),
                      if (userProvider.user.type == USER_TYPE.PROVIDER)
                        Expanded(
                          child: ReusableCard(
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                            title: AutoSizeText(
                              "HISTORY",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline6,
                              minFontSize: 10,
                            ),
                            onTap: () => ReviewMedicalHistory.show(
                              context: context,
                              consult: consult,
                            ),
                          ),
                        )
                    ],
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
