import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/models/consult-review/visit_review_model.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/prescription_details/prescription_list_item.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitNonPrescriptions extends StatelessWidget {
  final Consult consult;
  final VisitReviewData visitReviewData;

  const VisitNonPrescriptions({
    @required this.consult,
    @required this.visitReviewData,
  });

  static Future<void> show({
    BuildContext context,
    Consult consult,
    VisitReviewData visitReviewData,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitNonPrescriptions,
      arguments: {
        'consult': consult,
        'visitReviewData': visitReviewData,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    ScreenUtil.init(context);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Non-Prescriptions",
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
      body: Scrollbar(
        child: FadingEdgeScrollView.fromSingleChildScrollView(
          gradientFractionOnEnd: 0.1,
          gradientFractionOnStart: 0.1,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                ListItemsBuilder<TreatmentOptions>(
                  scrollable: false,
                  snapshot: null,
                  itemsList: visitReviewData.treatmentOptions
                      .where((e) => e.price == -1)
                      .toList(),
                  itemBuilder: (context, treatment) => PrescriptionListItem(
                    treatment: treatment,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
