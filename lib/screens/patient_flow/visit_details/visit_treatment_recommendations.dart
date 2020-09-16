import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_non_prescriptions.dart';
import 'package:Medicall/screens/patient_flow/visit_details/visit_prescriptions.dart';
import 'package:flutter/material.dart';

class VisitTreatmentRecommendations extends StatelessWidget {
  final Consult consult;
  final VisitReviewData visitReviewData;

  const VisitTreatmentRecommendations({
    @required this.consult,
    @required this.visitReviewData,
  });

  static Future<void> show({
    BuildContext context,
    Consult consult,
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitTreatments,
      arguments: {
        'consult': consult,
        'visitReviewData': visitReviewData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool containsPrescriptions = false;
    bool containsNonPrescriptions = false;
    for (TreatmentOptions treatmentOptions
        in visitReviewData.treatmentOptions) {
      if (treatmentOptions.price == -1) {
        containsNonPrescriptions = true;
      }
      if (treatmentOptions.price > -1) {
        containsPrescriptions = true;
      }

      if (containsNonPrescriptions && containsPrescriptions) {
        break;
      }
    }

    return Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Treatments",
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
        body: _buildChildren(
          context: context,
          containsNonPrescriptions: containsNonPrescriptions,
          containsPrescriptions: containsPrescriptions,
        ));
  }

  Widget _buildChildren({
    BuildContext context,
    bool containsPrescriptions = false,
    bool containsNonPrescriptions = false,
  }) {
    if (containsPrescriptions && containsNonPrescriptions) {
      return Column(
        children: [
          _buildListItem(
            context,
            "Prescriptions",
            "View the prescriptions prescribed by your provider for this visit",
            () => VisitPrescriptions.show(
              context: context,
              consult: consult,
              visitReviewData: visitReviewData,
            ),
          ),
          _buildListItem(
            context,
            "Non-Prescription Treatment Options",
            "View the treatments recommended by your provider that are non-prescriptions",
            () => VisitNonPrescriptions.show(
              context: context,
              consult: consult,
              visitReviewData: visitReviewData,
            ),
          ),
        ],
      );
    } else if (containsNonPrescriptions && !containsPrescriptions) {
      return _buildListItem(
        context,
        "Non-Prescription Treatment Options",
        "View the treatments recommended by your provider that are non-prescriptions",
        () => VisitNonPrescriptions.show(
          context: context,
          consult: consult,
          visitReviewData: visitReviewData,
        ),
      );
    } else if (containsPrescriptions && !containsNonPrescriptions) {
      return _buildListItem(
        context,
        "Prescriptions",
        "View the prescriptions prescribed by your provider for this visit",
        () => VisitPrescriptions.show(
          context: context,
          consult: consult,
          visitReviewData: visitReviewData,
        ),
      );
    } else {
      return _buildListItem(
        context,
        "Your provider did not give any treatment recommendations for your visit",
        "",
        null,
      );
    }
  }

  Widget _buildListItem(
      BuildContext context, String title, String subtitle, Function onTap) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: Card(
        elevation: 2,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          dense: false,
          title: Text(
            title,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.left,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.left,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
