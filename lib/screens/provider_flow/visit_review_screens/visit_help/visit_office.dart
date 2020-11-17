import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitOffice extends StatefulWidget {
  VisitOffice({Key key, Consult consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitOffice,
    );
  }

  @override
  _VisitOfficeState createState() => _VisitOfficeState();
}

class _VisitOfficeState extends State<VisitOffice> {
  @override
  Widget build(BuildContext context) {
    //List<String> selectedExamOptions = [];
    String picked = '';
    String picked1 = '';
    String picked2 = '';
    String picked3 = '';
    List<String> options = [
      "Not appropriate for teledermatology",
      "Prefer to see patient in person",
      "Will need further testing",
      "Other",
    ];
    List<String> boolOptions = [
      "Yes",
      "No",
    ];
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "",
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Why are you recommending an in person visit?",
                style: Theme.of(context).textTheme.headline6,
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
                picked: picked,
                onSelected: (String selected) async {
                  setState(() {
                    picked = selected;
                  });
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Would you like to complete the online visit?",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: RadioButtonGroup(
                labelStyle: Theme.of(context).textTheme.bodyText1,
                labels: boolOptions,
                picked: picked1,
                onSelected: (String selected) async {
                  setState(() {
                    picked1 = selected;
                  });
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Would you like issue a refund to the patient?",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: RadioButtonGroup(
                labelStyle: Theme.of(context).textTheme.bodyText1,
                labels: boolOptions,
                picked: picked2,
                onSelected: (String selected) async {
                  setState(() {
                    picked2 = selected;
                  });
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: RadioButtonGroup(
                labelStyle: Theme.of(context).textTheme.bodyText1,
                labels: [
                  "Notify my office so they can schedule in person follow-up for the patient"
                ],
                picked: picked3,
                onSelected: (String selected) async {
                  setState(() {
                    picked3 = selected;
                  });
                },
              ),
            ),
            Expanded(
              child: ContinueButton(
                title: "Continue",
                width: ScreenUtil.screenWidthDp - 60,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
