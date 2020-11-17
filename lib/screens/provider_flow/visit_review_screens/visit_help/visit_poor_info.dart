import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitPoorInfo extends StatefulWidget {
  VisitPoorInfo({Key key, Consult consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitPoorInfo,
    );
  }

  @override
  _VisitPoorInfoState createState() => _VisitPoorInfoState();
}

class _VisitPoorInfoState extends State<VisitPoorInfo> {
  @override
  Widget build(BuildContext context) {
    //List<String> selectedExamOptions = [];
    String picked = '';
    List<String> options = [
      "Clinical History",
      "Photographs",
      "Other",
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
              "Is there particular information that is Missing, inadequate, or of poor quality?",
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
