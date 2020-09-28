import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Shared/visit_information/review_visit_information.dart';
import 'package:Medicall/screens/provider_flow/dashboard/provider_dashboard_list_item.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reclassify_visit.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/view_patient_id.dart';
import 'package:Medicall/screens/shared/chat/chat_screen.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisitOverview extends StatelessWidget {
  final String consultId;
  final PatientUser patientUser;

  const VisitOverview({
    @required this.consultId,
    @required this.patientUser,
  });

  static Future<void> show({
    BuildContext context,
    String consultId,
    PatientUser patientUser,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitOverview,
      arguments: {
        'consultId': consultId,
        'patientUser': patientUser,
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
          stream: firestoreDatabase.consultStream(consultId: this.consultId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Consult consult = snapshot.data;
              consult.patientUser = this.patientUser;
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
                      "VISIT INFORMATION",
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
                      "VIEW PATIENT IDENTIFICATION",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onPressed: () => ViewPatientID.show(
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
                      "MESSAGE PATIENT",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onPressed: () => navigateToChatScreen(context, consult),
                    padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SignInButton(
              text: getContinueBtnText(consult).toUpperCase(),
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
      return () async => navigateToReclassifyScreen(context, consult);
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
      return "Signed";
    }
  }

  Future<void> navigateToReclassifyScreen(
      BuildContext context, Consult consult) async {
    NonAuthDatabase nonAuthDatabase =
        Provider.of<NonAuthDatabase>(context, listen: false);
    List<String> totalSymptoms = await nonAuthDatabase.symptomsListByName();
    return ReclassifyVisit.show(
      context: context,
      consult: consult,
      totalSymptoms: totalSymptoms,
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
      await navigateToReclassifyScreen(context, consult);
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
    } else {
      navigateToReclassifyScreen(context, consult);
    }
  }

  void navigateToChatScreen(BuildContext context, Consult consult) async {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    final channel = chatProvider.client.channel('messaging', id: consult.uid);
    ChatScreen.show(
      context: context,
      channel: channel,
      consult: consult,
    );
  }
}
