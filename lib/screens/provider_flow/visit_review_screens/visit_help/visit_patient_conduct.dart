import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitPatientConduct extends StatefulWidget {
  VisitPatientConduct({Key key, Consult consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitPatientConduct,
    );
  }

  @override
  _VisitPatientConductState createState() => _VisitPatientConductState();
}

class _VisitPatientConductState extends State<VisitPatientConduct> {
  @override
  Widget build(BuildContext context) {
    //List<String> selectedExamOptions = [];
    String picked = '';
    String input0 = '';
    List<String> options = [
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                initialValue: input0,
                autocorrect: true,
                keyboardType: TextInputType.text,
                onChanged: (String selected) async {
                  setState(() {
                    input0 = selected;
                  });
                },
                style: Theme.of(context).textTheme.bodyText2,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(90),
                  ),
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(100, 100, 100, 1),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withAlpha(20),
                  labelText: "Can you please tell us more?",
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                "Would you like the Medicall customer service team to help address this issue?",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
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
      ),
    );
  }
}
