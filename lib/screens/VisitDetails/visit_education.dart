import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_card.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitEducation extends StatelessWidget {
  final Consult consult;
  final VisitReviewData visitReviewData;

  const VisitEducation({
    @required this.consult,
    @required this.visitReviewData,
  });

  static Future<void> show({
    BuildContext context,
    Consult consult,
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitEducation,
      arguments: {
        'consult': consult,
        'visitReviewData': visitReviewData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Visit Education",
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
                })
          ]),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (Map<String, String> eduItem
                in visitReviewData.educationalOptions)
              ..._buildEduItem(
                  context, eduItem.keys.first, eduItem.values.first),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEduItem(
    BuildContext context,
    String name,
    String link,
  ) {
    return [
      Container(
        margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: ReusableCard(
          title: Text(
            name,
            style: Theme.of(context).textTheme.headline5,
          ),
          onTap: () async {
            String url = link;

            if (await canLaunch(url)) {
              await launch(
                url,
                forceSafariVC: true,
                forceWebView: true,
              );
            } else {
              throw 'Could not launch $url';
            }
          },
          subtitle: "Additional information",
          trailing: Icon(
            Icons.launch,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      )
    ];
  }
}
