import 'package:Medicall/screens/Questions/buildQuestions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Medicall/globals.dart' as globals;

class MedHistoryQuestionsScreen extends StatefulWidget {
  final globals.ConsultData data;

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
  Future _future;

  @override
  void initState() {
    super.initState();
    _future = Firestore.instance
        .document('services/dermatology/symptoms/' +
            widget.data.consultType.toLowerCase())
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
            print(historyFormKey.currentState.value);
            var listThis = historyFormKey.currentState.value.values.toList();
            widget.data.historyQuestions = [];
            for (var i = 0; i < listThis.length; i++) {
              widget.data.historyQuestions.add({
                'question': widget.data.stringListQuestions[i],
                'answers': listThis[i]
              });
            }
            Navigator.pushNamed(context, '/questionsUpload',
                arguments: widget.data);
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
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          return FormBuilder(
                              key: historyFormKey,
                              child: Column(
                                  children: BuildQuestions().buildQuestions(
                                      snapshot.data.data,
                                      'medical_history_questions',
                                      widget.data.provider,
                                      widget)));
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
