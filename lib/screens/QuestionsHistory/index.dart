import 'package:flutter/material.dart';
// import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
// import 'package:Medicall/models/question_model.dart';
// import 'package:Medicall/models/providers_model.dart';
import 'package:flutter_alert/flutter_alert.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

class QuestionsHistoryScreen extends StatefulWidget {
  final String selectedProvider;

  const QuestionsHistoryScreen({Key key, @required this.selectedProvider})
      : super(key: key);

  @override
  _QuestionsHistoryScreenState createState() => _QuestionsHistoryScreenState();
}

class _QuestionsHistoryScreenState extends State<QuestionsHistoryScreen> {
  GlobalKey<FormBuilderState> _qHistoryScreenKey0 = GlobalKey();
  GlobalKey<FormBuilderState> _qHistoryScreenKey1 = GlobalKey();
  GlobalKey<FormBuilderState> _qHistoryScreenKey2 = GlobalKey();
  GlobalKey<FormBuilderState> _qHistoryScreenKey3 = GlobalKey();
  GlobalKey<FormBuilderState> _qHistoryScreenKey4 = GlobalKey();
  GlobalKey<FormBuilderState> _qHistoryScreenKey5 = GlobalKey();
  var data;
  bool autoValidate = true;
  bool readOnly = false;

  @override
  void initState() {
    super.initState();
  }

  void _showMessageDialog(String msg) {
    showAlert(context: context, title: "Notice", body: msg);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'Medical History Questions',
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () {
          var allErrorsMsg = '';
          _qHistoryScreenKey0.currentState.save();
          if (_qHistoryScreenKey0.currentState.validate()) {
            print('validationSucceded');
            print(_qHistoryScreenKey0.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey0.currentState.formControls[0].attribute
                    .split(' ')[1] +
                ' is not filled out properly please review it. \n \n';
          }
          _qHistoryScreenKey1.currentState.save();
          if (_qHistoryScreenKey1.currentState.validate()) {
            print('validationSucceded');
            print(_qHistoryScreenKey1.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey1.currentState.formControls[0].attribute
                    .split(' ')[1] +
                ' is not filled out properly please review it. \n \n';
          }
          _qHistoryScreenKey2.currentState.save();
          if (_qHistoryScreenKey2.currentState.validate()) {
            print('validationSucceded');
            print(_qHistoryScreenKey2.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey2.currentState.formControls[0].attribute
                    .split(' ')[1] +
                ' is not filled out properly please review it. \n \n';
          }
          _qHistoryScreenKey3.currentState.save();
          if (_qHistoryScreenKey3.currentState.validate()) {
            print('validationSucceded');
            print(_qHistoryScreenKey3.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey3.currentState.formControls[0].attribute
                    .split(' ')[1] +
                ' is not filled out properly please review it. \n \n';
          }
          _qHistoryScreenKey4.currentState.save();
          if (_qHistoryScreenKey4.currentState.validate()) {
            print('validationSucceded');
            print(_qHistoryScreenKey4.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey4.currentState.formControls[0].attribute
                    .split(' ')[1] +
                ' is not filled out properly please review it. \n \n';
          }
          _qHistoryScreenKey5.currentState.save();
          if (_qHistoryScreenKey5.currentState.validate()) {
            print('validationSucceded'); 
            print(_qHistoryScreenKey5.currentState.value);
            //Navigator.pushNamed(context, '/questionsUpload');
          } else {
            allErrorsMsg += 'Question #' +
                _qHistoryScreenKey5.currentState.formControls[0].attribute
                    .split(' ')[1] +
                ' is not filled out properly please review it. \n \n';
          }
          if(allErrorsMsg.length > 0){
            _showMessageDialog(allErrorsMsg);
          }else{
            Navigator.pushNamed(context, '/questionsUpload');
          }
        }, // Switch tabs

        child: Text(
          'CONTINUE',
          style: TextStyle(
            color: Colors.white,
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
                context,
                key: _qHistoryScreenKey0,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.switchInput(
                      label: Text('#1. Have you previously seen ' +
                          widget.selectedProvider),
                      attribute: 'question 1',
                      
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixText: 'Yes',
                        suffixStyle: TextStyle(fontSize: 12),
                      ),
                      value: false,
                      validator: (value) {
                        if (!value)
                          return 'Have you previously seen ' +
                              widget.selectedProvider;
                      }),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      '#2. Do any of the following symptoms apply to this skin lesion? (Patient checks all that apply)'),
                ),
              ),
              FormBuilder(
                context,
                key: _qHistoryScreenKey1,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.checkboxList(
                    decoration:
                        InputDecoration(border: InputBorder.none, hintText: ''),
                    attribute: 'question 2',
                    require: true,
                    validator: (value) {
                      if (value.length <= 0) {
                        return 'This is required, please review';
                      }
                    },
                    options: [
                      FormBuilderInputOption(value: 'Asthma'),
                      FormBuilderInputOption(value: 'Dermatomyositis'),
                      FormBuilderInputOption(value: 'Diabetes'),
                      FormBuilderInputOption(
                          value: 'Eczema (atopic dermatitis)'),
                      FormBuilderInputOption(value: 'Food allergies'),
                      FormBuilderInputOption(value: 'Lupus'),
                      FormBuilderInputOption(value: 'Psoriasis'),
                      FormBuilderInputOption(value: 'Rheumatoid arthritis'),
                      FormBuilderInputOption(value: 'History of skin cancer'),
                      FormBuilderInputOption(value: 'Neuromuscular disorders'),
                      FormBuilderInputOption(value: 'Rosacea'),
                      FormBuilderInputOption(value: 'Seasonal allergies'),
                      FormBuilderInputOption(value: 'None of the above'),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Text(
                    '#3. Do you have any other current medical conditions or important past medical history? (anything for which you see a doctor or take medication is useful to know)'),
              ),
              FormBuilder(
                context,
                key: _qHistoryScreenKey2,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_MULTILINE_TEXT,
                    attribute: "question 3",
                    decoration: InputDecoration(
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.1)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
                      ),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(35, 179, 232, 1),
                      ),
                    ),
                    value: "",
                    require: false,
                    maxLines: 10,
                    autovalidate: true,
                  ),
                ],
              ),
              FormBuilder(
                context,
                key: _qHistoryScreenKey3,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.switchInput(
                      label: Text(
                          '#4. Are there any medication that you take or use regularly? (Including over-the-counter medications and supplements)'),
                      attribute: 'question 4',
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      value: false,
                      validator: (value) {
                        if (!value)
                          return 'Are there any medication that you take or use regularly? (Including over-the-counter medications and supplements)';
                      }),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '#5. What type of prescription coverage do you have?',
                  ),
                ),
              ),
              DropdownButtonHideUnderline(
                child: FormBuilder(
                  context,
                  key: _qHistoryScreenKey4,
                  autovalidate: autoValidate,
                  readonly: readOnly,
                  controls: [
                    FormBuilderInput.dropdown(
                      
                      attribute: 'question 5',
                      require: true,
                      value: 'I don\'t know',
                      validator: (value) {
                        if (value.length <= 0) {
                          return 'This is required, please review';
                        }
                      },
                      decoration: InputDecoration(
                        prefixText: '    ',
                        hintText: '',
                        suffixText: '    ',
                        fillColor: Colors.grey[10],
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                      ),
                      options: [
                        FormBuilderInputOption(value: 'Brand name and generic'),
                        FormBuilderInputOption(value: 'Generic only'),
                        FormBuilderInputOption(value: 'Medicaid'),
                        FormBuilderInputOption(value: 'I don\'t know'),
                        FormBuilderInputOption(
                            value: 'I don’t have health insurance'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Text(
                    '#6. Is there anything else you\'d like to ask or share with your doctor? (it is optional)'),
              ),
              FormBuilder(
                context,
                key: _qHistoryScreenKey5,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.textField(
                    type: FormBuilderInput.TYPE_MULTILINE_TEXT,
                    attribute: "question 6",
                    decoration: InputDecoration(
                      fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black.withOpacity(0.1)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(241, 100, 119, 1)),
                      ),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(35, 179, 232, 1),
                      ),
                    ),
                    value: "",
                    require: false,
                    maxLines: 10,
                    autovalidate: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
