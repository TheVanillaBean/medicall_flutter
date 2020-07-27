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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        title: Text("Get Ready"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pushNamed('/dashboard');
              })
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 40, 40, 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  "We will ask a few questions about your health and then focus on the reason for your visit.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  "It is important you answer the questions carefully and provide complete information.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 80),
              ],
            ),
            Container(
              child: FormBuilder(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderCheckboxList(
                          initialValue:
                              "No recent changes in my medical history",
                          attribute: "medhistory",
                          options: [
                            FormBuilderFieldOption(
                                value:
                                    'No recent changes in my medical history'),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton(
                color: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () async {
                  QuestionsScreen.show(
                    context: context,
                    consult: consult,
                  );
                },
                padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Start Visit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
