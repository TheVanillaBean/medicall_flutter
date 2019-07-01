import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Medicall/screens/Questions/buildQuestions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomQuestionsScreen extends StatefulWidget {
  final data;

  const SymptomQuestionsScreen({Key key, @required this.data})
      : super(key: key);
  @override
  _SymptomQuestionsScreenState createState() => _SymptomQuestionsScreenState();
}

class _SymptomQuestionsScreenState extends State<SymptomQuestionsScreen> {
  GlobalKey<FormBuilderState> screeningFormKey = GlobalKey();
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  var screeningQuestions;
  var medicalHistoryQuestions;
  bool showSegmentedControl = true;
  ConsultData _consult = ConsultData();

  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var perfConsult = jsonDecode(pref.getString('consult'));
    _consult.consultType = perfConsult["consultType"];
    _consult.screeningQuestions = perfConsult["screeningQuestions"];
    _consult.historyQuestions = perfConsult["historyQuestions"];
    return _consult.screeningQuestions;
  }

  setConsult() async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();
    int index = 0;
    screeningFormKey.currentState.value.forEach((k, v) {
      _consult.screeningQuestions[index]["answer"] =
          screeningFormKey.currentState.value[k];
      index++;
    });
    String currentConsultString = jsonEncode(_consult);
    await _thisConsult.setString("consult", currentConsultString);
    return jsonDecode(_thisConsult.getString('consult'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Screening Questions',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          screeningFormKey.currentState.save();
          if (screeningFormKey.currentState.validate()) {
            print('validationSucceded');
            //print(screeningFormKey.currentState.value);
            await setConsult();

            Navigator.pushNamed(context, '/selectProvider',
                arguments: {'user': medicallUser});
          } else {
            print('External FormValidation failed');
          }
        }, // Switch tabs

        child: Text(
          'CONTINUE',
          style: TextStyle(
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: FutureBuilder(
              future: getConsult(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Press button to start');
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          return buildQuestions(
                              _consult.screeningQuestions,
                              'screening_questions',
                              null,
                              widget,
                              screeningFormKey);
                        }
                      }
                    }
                }
              }),
        ),
      ),
    );
  }
}
