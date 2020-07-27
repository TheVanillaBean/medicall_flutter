import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/sign_in_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/review_visit_information.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_list_item.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisitOverview extends StatelessWidget {
  final Consult consult;

  const VisitOverview({@required this.consult});

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
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Visit Overview",
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _buildChildren(context),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProviderDashboardListItem(
          consult: consult,
          onTap: null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "REVIEW VISIT INFORMATION",
        onPressed: () => {},
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "DIAGNOSIS & TREATMENT PLAN",
        onPressed: navigateToVisitInformationScreen(context),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "MESSAGE PATIENT",
        onPressed: () => {},
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      CustomFlatButton(
        text: "REFUND PATIENT FEE",
        onPressed: () => {},
      ),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: SignInButton(
              text: getContinueBtnText(),
              height: 8,
              color: getContinueBtnColor(),
              textColor: Colors.white,
              onPressed: navigateToVisitInformationScreen(context),
            ),
          ),
        ),
      )
    ];
  }

  Color getContinueBtnColor() {
    if (consult.state == ConsultStatus.PendingReview) {
      return Colors.blue;
    } else if (consult.state == ConsultStatus.InReview) {
      return Colors.orange;
    } else {
      return Colors.deepOrangeAccent;
    }
  }

  String getContinueBtnText() {
    if (consult.state == ConsultStatus.PendingReview) {
      return "Begin Diagnosis & Treatment Plan";
    } else if (consult.state == ConsultStatus.InReview) {
      return "Continue Diagnosis & Treatment Plan";
    } else {
      return "Sign and Complete Visit";
    }
  }

  Function navigateToVisitInformationScreen(BuildContext context) {
    return consult.state == ConsultStatus.PendingReview
        ? () => _showDialog(context)
        : () => ReviewVisitInformation.show(
              context: context,
              consult: consult,
            );
  }

  Future<void> _showDialog(BuildContext context) async {
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
      ReviewVisitInformation.show(
        context: context,
        consult: consult,
      );
    }
  }
}
