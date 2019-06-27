import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Medicall/screens/Questions/buildQuestions.dart';

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
  var _buildClass = BuildQuestions();
  bool readOnly = false;
  double formSpacing = 20;
  var screeningQuestions;
  var medicalHistoryQuestions;
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
  void dispose() {
    super.dispose();
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
        onPressed: () {
          screeningFormKey.currentState.save();
          if (screeningFormKey.currentState.validate()) {
            print('validationSucceded');
            //print(screeningFormKey.currentState.value);
            var listThis = screeningFormKey.currentState.value.values.toList();
            _consult.screeningQuestions = [];
            for (var i = 0; i < listThis.length; i++) {
              _consult.screeningQuestions.add({
                'question': _consult.stringListQuestions[i],
                'answers': listThis[i]
              });
            }
            Navigator.pushNamed(context, '/selectProvider',
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
                          return FormBuilder(
                              key: screeningFormKey,
                              child: Column(
                                children: _buildClass.buildQuestions(
                                    snapshot.data.data,
                                    'screening_questions',
                                    null,
                                    widget),
                              ));
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
