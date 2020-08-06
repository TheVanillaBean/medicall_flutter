import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult-review/consult_review_options_model.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/review_visit_information.dart';
import 'package:Medicall/screens/ConsultReview/visit_review.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_list_item.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisitOverview extends StatelessWidget {
  final Consult consultOld;

  const VisitOverview({@required this.consultOld});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitOverview,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Visit Overview",
        theme: Theme.of(context),
      ),
      body: StreamBuilder<Consult>(
          stream: firestoreDatabase.consultStream(consultId: consultOld.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Consult consult = snapshot.data;
              consult.patientUser = consultOld.patientUser;
              consult.providerUser = userProvider.user as ProviderUser;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildChildren(context, firestoreDatabase, consult),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  List<Widget> _buildChildren(
      BuildContext context, FirestoreDatabase db, Consult consult) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProviderDashboardListItem(
          consult: consult,
          onTap: null,
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    color: Colors.white,
                    disabledColor: Colors.grey.withAlpha(40),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "REVIEW VISIT INFORMATION",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onPressed: () => ReviewVisitInformation.show(
                      context: context,
                      consult: consult,
                    ),
                    padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
//            Row(
//              children: <Widget>[
//                Expanded(
//                  child: RaisedButton(
//                    color: Colors.white,
//                    disabledColor: Colors.grey.withAlpha(40),
//                    elevation: 3,
//                    shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(12)),
//                    child: Text(
//                      "DIAGNOSIS & TREATMENT PLAN",
//                      style: Theme.of(context).textTheme.headline6,
//                    ),
//                    onPressed: onContinueBtnPressed(context, db, consult),
//                    padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
//                  ),
//                ),
//              ],
//            )
          ],
        ),
      ),
//      CustomFlatButton(
//        text: "MESSAGE PATIENT",
//        onPressed: () => {},
//      ),
//      Padding(
//        padding: const EdgeInsets.symmetric(horizontal: 16),
//        child: Divider(),
//      ),
//      CustomFlatButton(
//        text: "REFUND PATIENT FEE",
//        onPressed: () => {},
//      ),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: SignInButton(
              text: getContinueBtnText(consult),
              height: 8,
              color: getContinueBtnColor(consult),
              textColor: Colors.white,
              onPressed: onContinueBtnPressed(context, db, consult),
            ),
          ),
        ),
      )
    ];
  }

  Function onContinueBtnPressed(
      BuildContext context, FirestoreDatabase db, Consult consult) {
    if (consult.state == ConsultStatus.PendingReview) {
      return () => _showBeginReviewDialog(context, consult);
    } else if (consult.state == ConsultStatus.InReview) {
      return () async => navigateToVisitReviewScreen(context, db, consult);
    } else if (consult.state == ConsultStatus.Completed) {
      return () async => _showSignReviewDialog(context, consult);
    } else {
      return null;
    }
  }

  Color getContinueBtnColor(Consult consult) {
    if (consult.state == ConsultStatus.PendingReview) {
      return Colors.blue;
    } else if (consult.state == ConsultStatus.InReview) {
      return Colors.orange;
    } else if (consult.state == ConsultStatus.Completed) {
      return Colors.deepOrangeAccent;
    } else {
      return Colors.deepPurpleAccent;
    }
  }

  String getContinueBtnText(Consult consult) {
    if (consult.state == ConsultStatus.PendingReview) {
      return "Begin Diagnosis & Treatment Plan";
    } else if (consult.state == ConsultStatus.InReview) {
      return "Continue Diagnosis & Treatment Plan";
    } else if (consult.state == ConsultStatus.Completed) {
      return "Sign and Complete Visit";
    } else {
      return "Visit Already Signed";
    }
  }

  Future<void> navigateToVisitReviewScreen(
      BuildContext context, FirestoreDatabase db, Consult consult) async {
    ConsultReviewOptions options =
        await db.consultReviewOptions(symptomName: "Hairloss");
    VisitReviewData visitReviewData =
        await db.visitReviewStream(consultId: consult.uid).first;
    if (visitReviewData == null) {
      visitReviewData = VisitReviewData();
    }
    return VisitReview.show(
      context: context,
      consult: consult,
      consultReviewOptions: options,
      visitReviewData: visitReviewData,
    );
  }

  Future<void> _showBeginReviewDialog(
      BuildContext context, Consult consult) async {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    final didPressYes = await PlatformAlertDialog(
      title: "Begin Visit Review",
      content:
          "Once you begin this visit review, the status of the visit will change to \"In-Review\", which the patient will see.",
      defaultActionText: "Begin Review",
      cancelActionText: "No, don't begin",
    ).show(context);

    if (didPressYes == true) {
      consult.state = ConsultStatus.InReview;
      await db.saveConsult(consultId: consult.uid, consult: consult);
      PatientUser patient =
          await db.userStream(USER_TYPE.PATIENT, consult.patientId).first;
      consult.patientUser = patient;
      await navigateToVisitReviewScreen(context, db, consult);
    }
  }

  Future<void> _showSignReviewDialog(
      BuildContext context, Consult consult) async {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    final didPressYes = await PlatformAlertDialog(
      title: "Sign Review",
      content:
          "Would you like to sign this review or edit it? Once you sign it, any additional changes will be made as addendums to the original review.",
      defaultActionText: "Yes, sign",
      cancelActionText: "No, edit ",
    ).show(context);

    if (didPressYes == true) {
      consult.state = ConsultStatus.Signed;
      await db.saveConsult(consultId: consult.uid, consult: consult);
      VisitReviewData visitReviewData =
          await db.visitReviewStream(consultId: consult.uid).first;
      await db.savePrescriptions(
          consultId: consult.uid,
          treatmentOptions: visitReviewData.treatmentOptions);
    } else {
      navigateToVisitReviewScreen(context, db, consult);
    }
  }
}
