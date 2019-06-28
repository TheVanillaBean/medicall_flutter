import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Questions/buildQuestions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
  var _buildClass = BuildQuestions();
  double formSpacing = 20;
  bool showSegmentedControl = true;
  Future _future;
  ConsultData _consult;

  @override
  void initState() {
    super.initState();
    _consult = widget.data['consult'];
    medicallUser = widget.data['user'];
    _future = Firestore.instance
        .document('services/dermatology/symptoms/' +
            _consult.consultType.toLowerCase())
        .get();
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
        onPressed: () {
          historyFormKey.currentState.save();
          if (historyFormKey.currentState.validate()) {
            print('validationSucceded');
            //print(historyFormKey.currentState.value);
            //_consult.historyQuestions = [];
            // for (var i = 0; i < historyFormKey.currentState.value.length; i++) {
            //   _consult.historyQuestions[i]["answers"] =
            //       historyFormKey.currentState.value[i];
            // }
            var listThis = historyFormKey.currentState.value.values.toList();

            var finalQuestionList = [];
            for (var i = 0; i < listThis.length; i++) {
              finalQuestionList.add({
                'question': _consult.stringListQuestions[i],
                'answers': listThis[i]
              });
            }
            _consult.historyQuestions = finalQuestionList;
            Navigator.pushNamed(context, '/questionsUpload',
                arguments: {'consult': _consult, 'user': medicallUser});
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
              future: _future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Press button to start');
                  case ConnectionState.waiting:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.85,
                        ),
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          width: 50,
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        )
                      ],
                    );
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          // _consult.historyQuestions =
                          //     snapshot.data.data["medical_history_questions"];
                          var questionWidget = _buildClass.buildQuestions(
                              snapshot.data.data,
                              'medical_history_questions',
                              _consult.provider,
                              widget);
                          _consult.stringListQuestions = questionWidget[1];
                          return FormBuilder(
                              key: historyFormKey,
                              child: Column(children: questionWidget[0]));
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
