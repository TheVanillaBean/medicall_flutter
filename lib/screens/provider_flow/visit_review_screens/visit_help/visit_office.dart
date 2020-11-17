import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitOffice extends StatefulWidget {
  VisitOffice({Key key}) : super(key: key);
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
    List<String> options = [
      "Inadequate/poor quality information",
      "Redirect patient to an office visit",
      "Patient satification concern",
      "Inappropriate patient conduct",
      "Other"
    ];
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "",
        theme: Theme.of(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
            child: Text(
              "Do you have one of these issues?",
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
          Expanded(
            child: ContinueButton(
              title: "Continue",
              width: ScreenUtil.screenWidthDp - 60,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
