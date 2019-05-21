import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Medicall/globals.dart' as globals;


class QuestionsScreeningScreen extends StatefulWidget {
  final globals.ConsultData data;

  const QuestionsScreeningScreen({Key key, @required this.data})
      : super(key: key);
  @override
  _QuestionsScreeningScreenState createState() =>
      _QuestionsScreeningScreenState();
}

class _QuestionsScreeningScreenState extends State<QuestionsScreeningScreen> {
  GlobalKey<FormBuilderState> _fbKey0 = GlobalKey();
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  bool showSegmentedControl = true;
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
          _fbKey0.currentState.save();
          if (_fbKey0.currentState.validate()) {
            print('validationSucceded');
            print(_fbKey0.currentState.value);
            List<String> _questionsData = [];
            _fbKey0.currentState.value.forEach(
              (string, item) => {
                _questionsData.add(item.toString()),
              }
            );
            widget.data.screeningQuestions = _questionsData;
              
            Navigator.pushNamed(context, '/selectProvider', arguments: widget.data);
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
          child: FormBuilder(
            key: _fbKey0,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'How long has this lesion been there? (patient selects one)',
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: FormBuilderDropdown(
                    attribute: "question1",
                    decoration: InputDecoration(
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                    items: [
                      '14 days or less',
                      'Between 2 weeks and 6 months',
                      'Between 6 months and 2 years',
                      'Between 2 years and 10 years',
                      'As long as I can remember'
                    ]
                        .map((gender) => DropdownMenuItem(
                            value: gender, child: Text("$gender")))
                        .toList(),
                    readonly: false,
                  ),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Do any of the following symptoms apply to this skin lesion? (Patient checks all that apply)',
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: FormBuilderDropdown(
                    attribute: "question2",
                    decoration: InputDecoration(
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                    items: [
                      'Pain',
                      'Itching',
                      'Bleeding',
                      'Scabbing',
                      'Recent change in size',
                      'Recent change in color'
                    ]
                        .map((gender) => DropdownMenuItem(
                            value: gender, child: Text("$gender")))
                        .toList(),
                    readonly: false,
                  ),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                DropdownButtonHideUnderline(
                  child: FormBuilderSwitch(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    label: Text(
                        'Have you ever been diagnosed with a skin cancer before?'),
                    attribute: "question3",
                    initialValue: false,
                  ),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                DropdownButtonHideUnderline(
                  child: FormBuilderSwitch(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    label: Text(
                        'Does anyone in your family have a history of melanoma?'),
                    attribute: "question4",
                    initialValue: false,
                  ),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                DropdownButtonHideUnderline(
                  child: FormBuilderSwitch(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    label: Text(
                        'Are you on medications that decrease the function of your immune system?'),
                    attribute: "question5",
                    initialValue: false,
                  ),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Is there anything else you want us to know about this skin lesion?',
                    ),
                  ),
                ),
                FormBuilderTextField(
                  attribute: "question6",
                  maxLines: 6,
                  decoration: InputDecoration(
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none),
                  validators: [
                    //FormBuilderValidators.required(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
