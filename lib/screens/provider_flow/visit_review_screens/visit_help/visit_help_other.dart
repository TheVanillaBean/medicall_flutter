import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/grouped_buttons/checkbox_group.dart';
import 'package:Medicall/common_widgets/grouped_buttons/radio_button_group.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/reusable_widgets/continue_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitHelpOther extends StatefulWidget {
  VisitHelpOther({Key key, Consult consult}) : super(key: key);
  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.visitHelpOther,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VisitHelpOtherState createState() => _VisitHelpOtherState();
}

class _VisitHelpOtherState extends State<VisitHelpOther> {
  @override
  Widget build(BuildContext context) {
    //List<String> selectedExamOptions = [];
    String picked = '';
    String input = '';
    List<String> options = [
      "Yes",
      "No",
    ];
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Other",
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
                child: Column(
                  children: [
                    Text(
                      "Can you please tell us more?",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: input,
                      autocorrect: true,
                      keyboardType: TextInputType.text,
                      minLines: 10,
                      maxLines: 300,
                      onChanged: (String selected) async {
                        input = selected;
                      },
                      style: Theme.of(context).textTheme.bodyText2,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(90),
                        ),
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(100, 100, 100, 1),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(20),
                      ),
                    ),
                  ],
                )),
            Divider(),
            Padding(
                padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
                child: Column(
                  children: [
                    Text(
                      "Would you like the Medicall customer service team to help address this issue?",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    RadioButtonGroup(
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      activeColor: Theme.of(context).colorScheme.primary,
                      labels: options,
                      picked: picked,
                      onSelected: (String selected) async {
                        picked = selected;
                      },
                    ),
                  ],
                )),
            ContinueButton(
              title: "Continue",
              width: ScreenUtil.screenWidthDp - 60,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
