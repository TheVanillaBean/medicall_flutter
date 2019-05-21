import 'package:flutter/material.dart';
// import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
// import 'package:Medicall/models/question_model.dart';
// import 'package:Medicall/models/providers_model.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Medicall/globals.dart' as globals;

//mport 'package:flutter_form_builder/flutter_form_builder.dart';

class QuestionsHistoryScreen extends StatefulWidget {
  final globals.ConsultData data;

  const QuestionsHistoryScreen({Key key, @required this.data})
      : super(key: key);

  @override
  _QuestionsHistoryScreenState createState() => _QuestionsHistoryScreenState();
}

class _QuestionsHistoryScreenState extends State<QuestionsHistoryScreen> {
  GlobalKey<FormBuilderState> _qHistoryScreenKey0 = GlobalKey();
  bool autoValidate = true;
  bool readOnly = false;
  List<String> _questionsData = [];
  double formSpacing = 20;
  @override
  void initState() {
    super.initState();
  }

  // void _showMessageDialog(String msg) {
  //   showAlert(context: context, title: 'Notice', body: msg);
  // }

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          var allErrorsMsg = '';
          _qHistoryScreenKey0.currentState.save();
          if (_qHistoryScreenKey0.currentState.validate()) {
            print('validationSucceded');
            print(_qHistoryScreenKey0.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey0.currentState.value.toString() +
                ' is not filled out properly please review it. \n \n';
          }
          if (allErrorsMsg.length > 0) {
            //_showMessageDialog(allErrorsMsg);
          } else {
            
            _qHistoryScreenKey0.currentState.value.forEach(
                (string, item) => (_questionsData.add(item.toString())));
            widget.data.historyQuestions = _questionsData;
            Navigator.pushNamed(context, '/questionsUpload',
                arguments: widget.data);
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
          child: Column(
            children: <Widget>[
              FormBuilder(
                key: _qHistoryScreenKey0,
                child: Column(
                  children: <Widget>[
                    DropdownButtonHideUnderline(
                      child: FormBuilderSwitch(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            border: InputBorder.none),
                        label: Text(
                            'Have you previously seen ' + widget.data.provider),
                        attribute: "question0",
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
                          'Do you have any of the following medical conditions? (you\'ll have a chance to tell your doctor about other medical conditions later.)',
                        ),
                      ),
                    ),
                    FormBuilderCheckboxList(
                        attribute: "question1",
                        initialValue: [""],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                        options: [
                          FormBuilderFieldOption(value: "Asthma"),
                          FormBuilderFieldOption(value: "Dermatomyositis"),
                          FormBuilderFieldOption(value: "Diabetes"),
                          FormBuilderFieldOption(
                              value: "Eczema (atopic dermatitis)"),
                          FormBuilderFieldOption(value: "Food allergies"),
                          FormBuilderFieldOption(value: "Lupus"),
                          FormBuilderFieldOption(value: "Psoriasis"),
                          FormBuilderFieldOption(value: "Rheumatoid arthritis"),
                          FormBuilderFieldOption(
                              value: "History of skin cancer"),
                          FormBuilderFieldOption(
                              value: "Neuromuscular disorders"),
                          FormBuilderFieldOption(value: "Rosacea"),
                          FormBuilderFieldOption(value: "Seasonal allergies"),
                        ]),
                    SizedBox(
                      height: formSpacing,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Do you have any other current medical conditions or important past medical history? (anything for which you see a doctor or take medication is useful to know)',
                        ),
                      ),
                    ),
                    FormBuilderTextField(
                      attribute: "question2",
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
                    SizedBox(
                      height: formSpacing,
                    ),
                    DropdownButtonHideUnderline(
                      child: FormBuilderSwitch(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            border: InputBorder.none),
                        label: Text(
                            'Are there any medication that you take or use regularly? (Including over-the-counter medications and supplements)'),
                        attribute: "question3",
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
                          'What type of prescription coverage do you have?',
                        ),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: FormBuilderDropdown(
                        attribute: "question4",
                        decoration: InputDecoration(
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            border: InputBorder.none),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                        items: [
                          'Brand name and generic',
                          'Generic only',
                          'Medicaid',
                          'I don\'t know',
                          'I don’t have health insurance',
                        ]
                            .map((input) => DropdownMenuItem(
                                value: input, child: Text("$input")))
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
                          'Is there anything else you\'d like to ask or share with your doctor? (it is optional)',
                        ),
                      ),
                    ),
                    FormBuilderTextField(
                      attribute: "question5",
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
              )

              // Padding(
              //   padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
              //   child: Text(
              //       '#6. Is there anything else you\'d like to ask or share with your doctor? (it is optional)'),
              // ),
              // FormBuilder(
              //   context,
              //   key: _qHistoryScreenKey5,
              //   autovalidate: autoValidate,
              //   readonly: readOnly,
              //   controls: [
              //     FormBuilderInput.textField(
              //       type: FormBuilderInput.TYPE_MULTILINE_TEXT,
              //       attribute: 'question 6',
              //       decoration: InputDecoration(
              //         fillColor: Color.fromRGBO(35, 179, 232, 0.1),
              //         filled: true,
              //         border: const OutlineInputBorder(
              //           borderSide:
              //               BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
              //         ),
              //         enabledBorder: OutlineInputBorder(
              //           borderSide:
              //               BorderSide(color: Colors.black.withOpacity(0.1)),
              //         ),
              //         focusedBorder: const OutlineInputBorder(
              //           borderSide:
              //               BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
              //         ),
              //         labelStyle: const TextStyle(
              //           color: Color.fromRGBO(35, 179, 232, 1),
              //         ),
              //       ),
              //       value: '',
              //       require: false,
              //       maxLines: 10,
              //       autovalidate: true,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
