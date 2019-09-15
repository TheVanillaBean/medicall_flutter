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
    getConsult().then((onValue) {
      setState(() {
        _consult.consultType = onValue["consultType"];
        _consult.screeningQuestions = onValue["screeningQuestions"];
        _consult.uploadQuestions = onValue["uploadQuestions"];
        _consult.historyQuestions = onValue["historyQuestions"];
        _consult.provider = onValue["provider"];
        _consult.providerTitles = onValue["providerTitles"];
        _consult.providerId = onValue["providerId"];
        if (_consult.provider != null && _consult.provider.length > 0) {
          _consult.historyQuestions[0]["question"] =
              _consult.historyQuestions[0]["question"] +
                  " " +
                  _consult.provider;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return jsonDecode(pref.getString('consult'));
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
                arguments: {'user': medicallUser, 'consult': _consult});
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
            child: BuildQuestions(
              data: {
                'data': _consult.historyQuestions,
                'questionIndex': 'medical_history_questions',
                'dynamicAdd': widget.data['dynamicAdd'],
                'widget': widget,
                'key': historyFormKey
              },
            )),
      ),
    );
  }
}
