import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_help_other.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_office.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_patient_conduct.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_patient_satisfaction.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_help/visit_poor_info.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitHelp extends StatefulWidget {
  final Consult consult;

  const VisitHelp({Key key, this.consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitHelp,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VisitHelpState createState() => _VisitHelpState();
}

class _VisitHelpState extends State<VisitHelp> {
  String selectedReason = VisitTroubleLabels.Poor_Quality;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Need Help?",
        theme: Theme.of(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
            child: Text(
              "Do you have one of these issues?",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: RadioButtonGroup(
              labelStyle: Theme.of(context).textTheme.bodyText1,
              labels: VisitTroubleLabels.allReasons,
              activeColor: Theme.of(context).colorScheme.primary,
              picked: this.selectedReason,
              onSelected: (String selected) =>
                  this.updateWith(selectedReason: selected),
            ),
          ),
          Expanded(
            child: ContinueButton(
              title: "Continue",
              width: ScreenUtil.screenWidthDp - 60,
              onTap: () {
                if (this.selectedReason == VisitTroubleLabels.Poor_Quality) {
                  VisitPoorInfo.show(context: context, consult: widget.consult);
                }
                if (this.selectedReason == VisitTroubleLabels.Redirect) {
                  VisitOffice.show(context: context, consult: widget.consult);
                }
                if (this.selectedReason ==
                    VisitTroubleLabels.Patient_Satisfaction) {
                  VisitPatientSatisfaction.show(
                      context: context, consult: widget.consult);
                }
                if (this.selectedReason ==
                    VisitTroubleLabels.Inappropriate_Conduct) {
                  VisitPatientConduct.show(
                      context: context, consult: widget.consult);
                }
                if (this.selectedReason == VisitTroubleLabels.Other) {
                  VisitHelpOther.show(
                      context: context, consult: widget.consult);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void updateWith({String selectedReason}) {
    setState(() {
      this.selectedReason = selectedReason ?? this.selectedReason;
    });
  }
}
