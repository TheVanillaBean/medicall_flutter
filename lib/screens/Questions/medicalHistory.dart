import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Questions/buildQuestions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedHistoryQuestionsScreen extends StatefulWidget {
  final data;

  const MedHistoryQuestionsScreen({Key key, @required this.data})
      : super(key: key);

  @override
  _MedHistoryQuestionsScreenState createState() =>
      _MedHistoryQuestionsScreenState();
}

class _MedHistoryQuestionsScreenState extends State<MedHistoryQuestionsScreen> {
  GlobalKey<FormBuilderState> historyFormKey = GlobalKey();
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  bool showSegmentedControl = true;
  ConsultData _consult = ConsultData();

  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var perfConsult = jsonDecode(pref.getString('consult'));
    _consult.consultType = perfConsult["consultType"];
    _consult.screeningQuestions = perfConsult["screeningQuestions"];
    _consult.historyQuestions = perfConsult["historyQuestions"];
    _consult.provider = perfConsult["provider"];
    _consult.providerId = perfConsult["providerId"];
    _consult.historyQuestions[0]["question"] =
        _consult.historyQuestions[0]["question"] + " " + _consult.provider;
    return _consult.screeningQuestions;
  }

  setConsult() async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();
    int index = 0;
    historyFormKey.currentState.value.forEach((k, v) {
      _consult.historyQuestions[index]["answer"] =
          historyFormKey.currentState.value[k];
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
          'Medical History Questions',
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
          historyFormKey.currentState.save();
          if (historyFormKey.currentState.validate()) {
            print('validationSucceded');
            //print(historyFormKey.currentState.value);
            await setConsult();
            Navigator.pushNamed(context, '/questionsUpload',
                arguments: {'user': medicallUser});
          } else {
            print('External FormValidation failed');
          }
        }, // Switch tabs

        child: Text(
          'CONTINUE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
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
                              _consult.historyQuestions,
                              'screening_questions',
                              null,
                              widget,
                              historyFormKey);
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
