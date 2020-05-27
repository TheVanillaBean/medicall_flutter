import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:Medicall/screens/Symptoms/medical_history_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class StartVisitScreen extends StatefulWidget {
  StartVisitScreen({Key key}) : super(key: key);

  @override
  _StartVisitScreenState createState() => _StartVisitScreenState();
}

class _StartVisitScreenState extends State<StartVisitScreen> {
  @override
  Widget build(BuildContext context) {
    Database db = Provider.of<Database>(context);
    MedicalHistoryState _newMedicalHistory =
        Provider.of<MedicalHistoryState>(context);
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
        ),
        body: Container(
            padding: EdgeInsets.fromLTRB(40, 40, 40, 0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Start your ' +
                          db.newConsult.consultType.toLowerCase() +
                          ' visit',
                      style: TextStyle(fontSize: 42),
                    ),
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
                      if (_newMedicalHistory.getnewMedicalHistory()) {
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
            )));
  }
}
