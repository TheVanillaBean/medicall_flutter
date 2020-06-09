import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Questions/questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class StartVisitScreen extends StatelessWidget {
  final Symptom symptom;
  final Consult consult;

  const StartVisitScreen({@required this.symptom, @required this.consult});

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.startVisit,
      arguments: {
        'symptom': symptom,
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Start your visit!"),
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
              height: 80,
              child: FormBuilder(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderRadio(attribute: 'medhistory', options: [
                        FormBuilderFieldOption(
                          value: true,
                          label: 'Has your medical history changed recently?',
                        )
                      ])
                    ],
                  )),
            ),
            Positioned(
              bottom: 20,
              child: FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () async {
                  QuestionsScreen.show(
                    context: context,
                    consult: consult,
                    symptom: symptom,
                  );
                },
                padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
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
