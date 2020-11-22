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
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    //List<String> selectedExamOptions = [];
    String picked;
    List<String> options = [
      "Inadequate/poor quality information",
      "Redirect patient to an office visit",
      "Patient satisfaction concern",
      "Inappropriate patient conduct",
      "Other"
    ];
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
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 36),
          //   child: CheckboxGroup(
          //     labels: options,
          //     onSelected: (selected) {
          //       setState(() {});
          //     },
          //     checked: selectedExamOptions,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: RadioButtonGroup(
              labelStyle: Theme.of(context).textTheme.bodyText1,
              labels: options,
              activeColor: Theme.of(context).colorScheme.primary,
              picked: picked != null && picked.length > 0 ? picked : null,
              onSelected: (String selected) async {
                picked = selected;
              },
            ),
          ),
          Expanded(
            child: ContinueButton(
              title: "Continue",
              width: ScreenUtil.screenWidthDp - 60,
              onTap: () {
                if (picked == options[0]) {
                  VisitPoorInfo.show(context: context, consult: widget.consult);
                }
                if (picked == options[1]) {
                  VisitOffice.show(context: context, consult: widget.consult);
                }
                if (picked == options[2]) {
                  VisitPatientSatisfaction.show(
                      context: context, consult: widget.consult);
                }
                if (picked == options[3]) {
                  VisitPatientConduct.show(
                      context: context, consult: widget.consult);
                }
                if (picked == options[4]) {
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
}
