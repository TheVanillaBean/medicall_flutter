import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitOffice extends StatefulWidget {
  final Consult consult;

  VisitOffice({Key key, this.consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitOffice,
      arguments: {
        'consult': consult,
      },
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
    List<String> picked3 = [];
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
        title: "Office Visit",
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
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: RadioButtonGroup(
                labelStyle: Theme.of(context).textTheme.bodyText1,
                activeColor: Theme.of(context).colorScheme.primary,
                labels: options,
                picked: picked != null && picked.length > 0 ? picked : null,
                onSelected: (String selected) async {
                  picked = selected;
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Would you like to complete the online visit?",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: RadioButtonGroup(
                labelStyle: Theme.of(context).textTheme.bodyText1,
                activeColor: Theme.of(context).colorScheme.primary,
                labels: boolOptions,
                picked: picked1 != null && picked1.length > 0 ? picked1 : null,
                onSelected: (String selected) async {
                  picked1 = selected;
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Would you like issue a refund to the patient?",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: RadioButtonGroup(
                labelStyle: Theme.of(context).textTheme.bodyText1,
                activeColor: Theme.of(context).colorScheme.primary,
                labels: boolOptions,
                picked: picked2 != null && picked2.length > 0 ? picked2 : null,
                onSelected: (String selected) async {
                  picked2 = selected;
                },
              ),
            ),
            Divider(),
            CheckboxGroup(
              labelStyle: Theme.of(context).textTheme.bodyText1,
              activeColor: Theme.of(context).colorScheme.primary,
              labels: [
                "Notify my office so they can schedule in person follow-up for the patient"
              ],
              checked: picked3 != null && picked3.length > 0 ? picked3 : null,
              onSelected: (List<String> selected) async {
                picked3 = selected;
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(36, 20, 36, 15),
              child: ContinueButton(
                title: "Continue",
                width: ScreenUtil.screenWidthDp,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
