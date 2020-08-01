import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Questions/questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class StartVisitScreen extends StatelessWidget {
  final Consult consult;

  const StartVisitScreen({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.startVisit,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Visit Questions",
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/dashboard');
                })
          ]),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 0, 40, 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "We will ask a few questions, first about your medical history and after we will focus on visit questions.",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      "It is important you answer the questions carefully and provide complete information.",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                )),
            Expanded(
              flex: 2,
              child: FormBuilder(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FormBuilderCheckboxList(
                          attribute: "medhistory",
                          options: [
                            FormBuilderFieldOption(
                                value:
                                    'I\'ve had a recent change in my medical history')
                          ])
                      // FormBuilderRadio(attribute: 'medhistory', options: [
                      //   FormBuilderFieldOption(
                      //     value: true,
                      //     label:
                      //         'I have no recent changes in my medical history',
                      //   )
                      // ]),
                    ],
                  )),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ReusableRaisedButton(
                  title: 'Start Visit',
                  onPressed: () async {
                    QuestionsScreen.show(
                      context: context,
                      consult: consult,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
