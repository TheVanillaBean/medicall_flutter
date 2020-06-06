import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Symptoms/medical_history_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class StartVisitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
    Database db = Provider.of<Database>(context, listen: false);
    MedicallUser medicallUser = Provider.of<UserProvider>(context).medicallUser;
    db.getUserMedicalHistory(medicallUser);
    MedicalHistoryState _newMedicalHistory =
        Provider.of<MedicalHistoryState>(context, listen: false);
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    db.newConsult.consultType != null
                        ? Text(
                            'Start your ' +
                                db.newConsult.consultType.toLowerCase() +
                                ' visit',
                            style: TextStyle(fontSize: 42),
                          )
                        : Text("Start your visit!"),
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
                              label:
                                  'Has your medical history changed recently?',
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
                      await db.getConsultQuestions();

                      db.newConsult.screeningQuestions =
                          db.consultQuestions.data["screening_questions"];

                      db.newConsult.uploadQuestions =
                          db.consultQuestions.data["upload_questions"];
                      if (_newMedicalHistory.getnewMedicalHistory() ||
                          formKey.currentState.fields['medHistory'] != null &&
                              !formKey.currentState.fields['medHistory']
                                  .currentState.value) {
                        _newMedicalHistory.setnewMedicalHistory(true);
                        Navigator.of(context).pushNamed('/questionsScreen');
                      } else {
                        _newMedicalHistory.setnewMedicalHistory(false);
                        Navigator.of(context).pushNamed('/questionsScreen');
                      }
                      Navigator.pushNamed(context, '/questionsScreen');
                    },
                    padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Continue',
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
            )));
  }
}
