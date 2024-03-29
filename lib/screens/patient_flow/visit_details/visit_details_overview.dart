import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Shared/visit_information/review_visit_information.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_doc_note.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_education.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_treatment_recommendations.dart';
import 'package:Medicall/screens/shared/chat/chat_screen.dart';
import 'package:Medicall/screens/shared/video_player/video_player.dart';
import 'package:Medicall/services/chat_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VisitDetailsOverview extends StatelessWidget {
  final Consult consult;

  const VisitDetailsOverview({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitDetailsOverview,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: this.consult.symptom + ' visit',
        subtitle: 'with ' +
            this.consult.providerUser.fullName +
            ', ' +
            this.consult.providerUser.professionalTitle +
            ' on ' +
            DateFormat('MM-dd-yyyy').format(this.consult.date).toString(),
        theme: Theme.of(context),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              PatientDashboardScreen.show(
                  context: context, pushReplaceNamed: true);
            },
          )
        ],
      ),
      body: this.consult.state == ConsultStatus.Signed
          ? _buildVisitReviewButtons(firestoreDatabase)
          : _buildOptionsForNonReviewed(context),
    );
  }

  SingleChildScrollView _buildOptionsForNonReviewed(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildCardButton(
            context,
            "Provider Note",
            MedicallIcons.clipboard_1,
            () {
              AppUtil().showFlushBar(
                  "This visit has not been reviewed yet", context);
            },
            consult.patientReviewNotifications,
          ),
          _buildCardButton(
            context,
            "Treatment Recommendations",
            Icons.local_pharmacy,
            () {
              AppUtil().showFlushBar(
                  "This visit has not been reviewed yet", context);
            },
            consult.patientReviewNotifications,
          ),
          _buildCardButton(
            context,
            "Further Learning",
            Icons.school,
            () {
              AppUtil().showFlushBar(
                  "This visit has not been reviewed yet", context);
            },
            consult.patientReviewNotifications,
          ),
          _buildCardButton(
            context,
            "Your Visit Information",
            Icons.assignment,
            () => {
              ReviewVisitInformation.show(
                context: context,
                consult: this.consult,
              ),
            },
            0,
          ),
          _buildCardButton(
            context,
            "Message Provider",
            Icons.message,
            () async {
              DateTime currentDate = DateTime.now();
              if (this.consult.chatClosed != null ||
                  currentDate.difference(this.consult.date).inDays > 3) {
                AppUtil().showFlushBar(
                    "The chat time window for this visit has passed", context);
              } else {
                await navigateToChatScreen(context);
              }
            },
            consult.patientMessageNotifications,
          ),
        ],
      ),
    );
  }

  StreamBuilder<VisitReviewData> _buildVisitReviewButtons(
      FirestoreDatabase firestoreDatabase) {
    return StreamBuilder<VisitReviewData>(
      stream: firestoreDatabase.visitReviewStream(consultId: this.consult.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Error retrieving visit information.",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildCardButton(
                context,
                "Provider Note",
                MedicallIcons.clipboard_1,
                () async => {
                  await VisitDocNote.show(
                    context: context,
                    consult: this.consult,
                    visitReviewData: snapshot.data,
                  ),
                },
                consult.patientReviewNotifications,
              ),
              _buildCardButton(
                context,
                "Treatment Recommendations",
                Icons.local_pharmacy,
                () async => {
                  await VisitTreatmentRecommendations.show(
                    context: context,
                    consult: this.consult,
                    visitReviewData: snapshot.data,
                  ),
                },
                consult.patientReviewNotifications,
              ),
              _buildCardButton(
                context,
                "Further Learning",
                Icons.school,
                () async => {
                  await VisitEducation.show(
                    context: context,
                    consult: this.consult,
                    visitReviewData: snapshot.data,
                  ),
                },
                consult.patientReviewNotifications,
              ),
              _buildCardButton(
                context,
                "Your Visit Information",
                Icons.assignment,
                () async => {
                  await ReviewVisitInformation.show(
                    context: context,
                    consult: this.consult,
                  ),
                },
                0,
              ),
              if (snapshot.data.videoNoteURL.length > 0)
                _buildCardButton(
                  context,
                  "Provider Video Note",
                  Icons.personal_video_rounded,
                  () async => await VideoPlayer.show(
                    context: context,
                    title: "Video Note",
                    url: snapshot.data.videoNoteURL,
                    fromNetwork: true,
                  ),
                  consult.patientReviewNotifications,
                ),
              _buildCardButton(
                context,
                "Message Provider",
                Icons.message,
                () async {
                  DateTime currentDate = DateTime.now();
                  if (this.consult.chatClosed != null ||
                      currentDate.difference(this.consult.date).inDays > 3) {
                    AppUtil().showFlushBar(
                        "The chat time window for this visit has passed",
                        context);
                  } else {
                    await navigateToChatScreen(context);
                  }
                },
                consult.patientMessageNotifications,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> navigateToChatScreen(BuildContext context) async {
    ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
    final channel =
        chatProvider.client.channel('messaging', id: this.consult.uid);
    FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    consult.patientMessageNotifications = 0;
    await database.saveConsult(consult: consult, consultId: consult.uid);
    ChatScreen.show(
      context: context,
      channel: channel,
      consult: this.consult,
    );
  }

  Widget _buildCardButton(BuildContext context, String title, IconData icon,
      Function onTap, int value) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Badge(
        padding: EdgeInsets.all(8),
        showBadge: value != 0 ? true : false,
        shape: BadgeShape.circle,
        position: BadgePosition.topEnd(top: -4, end: -2),
        badgeColor: Theme.of(context).colorScheme.primary,
        badgeContent: Text(
          '$value',
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                fontSize: 16,
                color: Colors.white,
              ),
        ),
        animationType: BadgeAnimationType.scale,
        animationDuration: Duration(milliseconds: 300),
        child: Card(
          elevation: 3,
          shadowColor: Colors.grey.withAlpha(120),
          borderOnForeground: false,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            dense: true,
            leading: Icon(
              icon,
              size: 25,
              color: Colors.grey,
            ),
            title: Text(title),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
