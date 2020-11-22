import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitPoorInfo extends StatefulWidget {
  final Consult consult;

  VisitPoorInfo({Key key, this.consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitPoorInfo,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VisitPoorInfoState createState() => _VisitPoorInfoState();
}

class _VisitPoorInfoState extends State<VisitPoorInfo> {
  @override
  Widget build(BuildContext context) {
    //List<String> selectedExamOptions = [];
    String picked;
    List<String> options = [
      "Clinical History",
      "Photographs",
      "Other",
    ];
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Visit Quality",
        theme: Theme.of(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 32, 36, 12),
            child: Text(
              "Is there particular information that is missing, inadequate, or of poor quality?",
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
              activeColor: Theme.of(context).colorScheme.primary,
              labels: options,
              picked: picked,
              onSelected: (String selected) async {
                picked = selected;
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
