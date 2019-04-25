// import 'package:flutter/material.dart';
// import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
// import 'package:Medicall/models/question_model.dart';

// class QuestionsScreeningScreen extends StatefulWidget {
//   @override
//   _QuestionsScreeningScreenState createState() =>
//       _QuestionsScreeningScreenState();
// }

// class _QuestionsScreeningScreenState extends State<QuestionsScreeningScreen> {
//   var _questions = Questions(questions: [
//     Question(
//         question: 'How long has this lesion been there? (patient selects one)',
//         options: [
//           '14 days or less',
//           'Between 2 weeks and 6 months',
//           'Between 6 months and 2 years',
//           'Between 2 years and 10 years',
//           'As long as I can remember',
//           'I’m not sure',
//         ],
//         type: 'multipleChoice',
//         userData: '14 days or less'),
//     Question(
//         question:
//             'Do any of the following symptoms apply to this skin lesion? (Patient checks all that apply)',
//         options: [
//           'Pain',
//           'Itching',
//           'Bleeding',
//           'Scabbing',
//           'Recent change in size',
//           'Recent change in color',
//         ],
//         type: 'multipleChoice',
//         userData: 'Pain'),
//     Question(
//         question: 'Have you ever been diagnosed with a skin cancer before?',
//         options: [
//           'Yes',
//           'No',
//         ],
//         type: 'multipleChoice',
//         userData: 'No'),
//     Question(
//         question: 'Does anyone in your family have a history of melanoma',
//         options: [
//           'Yes',
//           'No',
//         ],
//         type: 'multipleChoice',
//         userData: 'No'),
//     Question(
//         question:
//             'Are you on medications that decrease the function of your immune system?',
//         options: [
//           'Yes',
//           'No',
//         ],
//         type: 'multipleChoice',
//         userData: 'No'),
//     Question(
//         question:
//             'Is there anything else you want us to know about this skin lesion?',
//         options: [],
//         type: 'input',
//         userData: ''),
//   ]);

//   _questionBuilder(context, index) {
//     final item = _questions.questions[index];
//     List<DropdownMenuItem<dynamic>> newOptions = [];
//     for (var i = 0; i < item.options.length; i++) {
//       newOptions.add(DropdownMenuItem(
//         value: item.options[i],
//         child: new Text(item.options[i]),
//       ));
//     }
//     if (item.type == 'switch') {
//       return SwitchListTile(
//           title: Text(item.question),
//           value: item.userData,
//           onChanged: (val) {
//             //setState(() => _user.passions[User.PassionCooking] = val);
//             print(item.userData);
//           });
//     } else if (item.type == 'multipleChoice') {
//       return FormField(
//         builder: (FormFieldState state) {
//           return Padding(
//             padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
//             child: Column(
//               children: <Widget>[
//                 Text(item.question),
//                 InputDecorator(
//                   textAlign: TextAlign.center,
//                   decoration: InputDecoration(
//                     labelText: '',
//                     contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 15)
//                   ),
//                   isEmpty: item.userData == '',
//                   child: new DropdownButtonHideUnderline(

//                     child: new DropdownButton(
//                       isExpanded: true,
//                       value: item.userData,
//                       isDense: true,
//                       onChanged: (dynamic newValue) {
//                         item.userData = newValue;
//                         state.didChange(newValue);
//                       },

//                       items: newOptions,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     } else if (item.type == 'input') {
//       return Padding(
//         padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
//         child: Column(
//           children: <Widget>[
//             new Text(item.question),
//             new TextFormField(
//               keyboardType: TextInputType.multiline,
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   _buildQuestions(context) {
//     return ListView.builder(
//       // Let the ListView know how many items it needs to build
//       itemCount: _questions.questions.length,
//       // Provide a builder function. This is where the magic happens! We'll
//       // convert each item into a Widget based on the type of item it is.
//       itemBuilder: (context, index) => _questionBuilder(context, index),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         centerTitle: true,
//         backgroundColor: Color.fromRGBO(35, 179, 232, 1),
//         title: new Text(
//           'Screening Questions',
//           style: new TextStyle(
//             fontSize:
//                 Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
//           ),
//         ),
//         elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       bottomNavigationBar: new FlatButton(
//         padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
//         color: Color.fromRGBO(35, 179, 232, 1),
//         onPressed: () => Navigator.pushNamed(context, '/selectProvider'),
//         child: Text(
//           'CONTINUE',
//           style: TextStyle(
//             color: Colors.white,
//             letterSpacing: 2,
//           ),
//         ),
//       ),
//       body: new Container(
//         child: _buildQuestions(context),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class QuestionsScreeningScreen extends StatefulWidget {
  final String consultType;

  const QuestionsScreeningScreen({Key key, @required this.consultType}) : super(key: key);
  @override
  _QuestionsScreeningScreenState createState() =>
      _QuestionsScreeningScreenState();
}

class _QuestionsScreeningScreenState extends State<QuestionsScreeningScreen> {
  GlobalKey<FormBuilderState> _fbKey0 = GlobalKey();
  GlobalKey<FormBuilderState> _fbKey1 = GlobalKey();
  GlobalKey<FormBuilderState> _fbKey2 = GlobalKey();
  GlobalKey<FormBuilderState> _fbKey3 = GlobalKey();
  GlobalKey<FormBuilderState> _fbKey4 = GlobalKey();
  GlobalKey<FormBuilderState> _fbKey5 = GlobalKey();
  var data;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'Screening Questions',
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () {
          _fbKey0.currentState.save();
          if (_fbKey0.currentState.validate()) {
            print('validationSucceded');
            print(_fbKey0.currentState.value);
            Navigator.pushNamed(context, '/selectProvider');
          } else {
            print('External FormValidation failed');
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
                child: FormBuilder(
                  context,
                  key: _fbKey0,
                  autovalidate: autoValidate,
                  readonly: readOnly,
                  controls: [
                    FormBuilderInput.dropdown(
                      attribute: 'question1',
                      require: true,
                      value: 'I’m not sure',
                      decoration: InputDecoration(
                        prefixText: '    ',
                        suffixText: '    ',
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                      ),
                      options: [
                        FormBuilderInputOption(value: '14 days or less'),
                        FormBuilderInputOption(
                            value: 'Between 2 weeks and 6 months'),
                        FormBuilderInputOption(
                            value: 'Between 6 months and 2 years'),
                        FormBuilderInputOption(
                            value: 'Between 2 years and 10 years'),
                        FormBuilderInputOption(
                            value: 'As long as I can remember'),
                        FormBuilderInputOption(value: 'I’m not sure'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Do any of the following symptoms apply to this skin lesion? (Patient checks all that apply)'),
                ),
              ),
              DropdownButtonHideUnderline(
                child: FormBuilder(
                  context,
                  key: _fbKey1,
                  autovalidate: autoValidate,
                  readonly: readOnly,
                  controls: [
                    FormBuilderInput.checkboxList(
                      decoration: InputDecoration.collapsed(
                          border: InputBorder.none,
                          hintText:
                              'Do any of the following symptoms apply to this skin lesion? (Patient checks all that apply)'),
                      attribute: 'question2',
                      require: false,
                      options: [
                        FormBuilderInputOption(value: 'Pain'),
                        FormBuilderInputOption(value: 'Itching'),
                        FormBuilderInputOption(value: 'Bleeding'),
                        FormBuilderInputOption(value: 'Scabbing'),
                        FormBuilderInputOption(value: 'Recent change in size'),
                        FormBuilderInputOption(value: 'Recent change in color'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(''),
              ),
              FormBuilder(
                context,
                key: _fbKey2,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.switchInput(
                      label: Text(
                          'Have you ever been diagnosed with a skin cancer before?'),
                      attribute: 'question3',
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      value: false,
                      validator: (value) {
                        if (!value)
                          return 'Have you ever been diagnosed with a skin cancer before?';
                      }),
                ],
              ),
              //
              FormBuilder(
                context,
                key: _fbKey3,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.switchInput(
                      label: Text(
                          'Does anyone in your family have a history of melanoma?'),
                      attribute: 'question4',
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      value: false,
                      validator: (value) {
                        if (!value)
                          return 'Does anyone in your family have a history of melanoma?';
                      }),
                ],
              ),
              FormBuilder(
                context,
                key: _fbKey4,
                autovalidate: autoValidate,
                readonly: readOnly,
                controls: [
                  FormBuilderInput.switchInput(
                      label: Text(
                          'Are you on medications that decrease the function of your immune system?'),
                      attribute: 'question5',
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      value: false,
                      validator: (value) {
                        if (!value)
                          return 'Are you on medications that decrease the function of your immune system?';
                      }),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Text(
                    'Is there anything else you want us to know about this skin lesion?'),
              ),
              FormBuilder(
                context,
                key: _fbKey5,
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
