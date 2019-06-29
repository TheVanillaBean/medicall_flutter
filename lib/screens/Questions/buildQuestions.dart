import 'package:Medicall/models/consult_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

buildQuestions(data, questionIndex, dynamicAdd, widget) {
  List<Widget> returnList = [];
  ValueChanged _onChanged;
  ConsultData _consult = widget.data['consult'];
  var questions = data[questionIndex];
  var stringList = [];

  for (var i = 0; i < questions.length; i++) {
    String question = questions[i]['question'];
    if (questionIndex == 'medical_history_questions' &&
        i == 0 &&
        dynamicAdd != null) {
      question = question + dynamicAdd;
    }
    stringList.add(question);
    List<dynamic> answers = questions[i]['answers'];
    if (answers[0] == 'Yes') {
      _onChanged = (val) {
        if (val.length > 2 && val[1] == 'Yes') {
          val.removeAt(1);
        }
        if (val.length > 2 && val[1] == 'No') {
          val.removeAt(1);
        }
      };
    }
    String type = questions[i]['type'];
    returnList.add(
      Column(
        children: <Widget>[
          i != 0
              ? SizedBox(
                  height: 20,
                )
              : SizedBox(height: 0),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question,
              ),
            ),
          ),
          type == 'dropdown'
              ? DropdownButtonHideUnderline(
                  child: FormBuilderDropdown(
                    initialValue: answers[0],
                    attribute: 'question' + i.toString(),
                    decoration: InputDecoration(
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                    items: answers
                        .map((lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    readonly: false,
                  ),
                )
              : type == 'checkbox'
                  ? FormBuilderCheckboxList(
                      leadingInput: true,
                      attribute: 'question' + i.toString(),
                      initialValue: [''],
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                      onChanged: _onChanged,
                      options: answers
                          .map((lang) => FormBuilderFieldOption(value: lang))
                          .toList(),
                    )
                  : type == 'switch'
                      ? DropdownButtonHideUnderline(
                          child: FormBuilderSwitch(
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                                border: InputBorder.none),
                            label: Text(''),
                            attribute: 'question' + i.toString(),
                            initialValue: false,
                          ),
                        )
                      : FormBuilderTextField(
                          initialValue: '',
                          attribute: 'question' + i.toString(),
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
    );
  }
  _consult.stringListQuestions = [];
  _consult.stringListQuestions = stringList;
  return returnList;
  //turn the snapshot to a list of widget as you like...
}

buildQuestions1(data, questionIndex, dynamicAdd, widget) {
  List<Widget> returnList = [];
  ValueChanged _onChanged;
  ConsultData _consult = widget.data['consult'];
  var questions = data[questionIndex];
  var stringList = [];

  for (var i = 0; i < questions.length; i++) {
    String question = questions[i]['question'];
    if (questionIndex == 'medical_history_questions' &&
        i == 0 &&
        dynamicAdd != null) {
      question = question + dynamicAdd;
    }
    stringList.add(question);
    List<dynamic> answers = questions[i]['answers'];
    if (answers[0] == 'Yes') {
      _onChanged = (val) {
        if (val.length > 2 && val[1] == 'Yes') {
          val.removeAt(1);
        }
        if (val.length > 2 && val[1] == 'No') {
          val.removeAt(1);
        }
      };
    }
    String type = questions[i]['type'];
    returnList.add(
      Column(
        children: <Widget>[
          i != 0
              ? SizedBox(
                  height: 20,
                )
              : SizedBox(height: 0),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question,
              ),
            ),
          ),
          type == 'dropdown'
              ? DropdownButtonHideUnderline(
                  child: FormBuilderDropdown(
                    initialValue: answers[0],
                    attribute: 'question' + i.toString(),
                    decoration: InputDecoration(
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                    items: answers
                        .map((lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    readonly: false,
                  ),
                )
              : type == 'checkbox'
                  ? FormBuilderCheckboxList(
                      leadingInput: true,
                      attribute: 'question' + i.toString(),
                      initialValue: [''],
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                      onChanged: _onChanged,
                      options: answers
                          .map((lang) => FormBuilderFieldOption(value: lang))
                          .toList(),
                    )
                  : type == 'switch'
                      ? DropdownButtonHideUnderline(
                          child: FormBuilderSwitch(
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                                border: InputBorder.none),
                            label: Text(''),
                            attribute: 'question' + i.toString(),
                            initialValue: false,
                          ),
                        )
                      : FormBuilderTextField(
                          initialValue: '',
                          attribute: 'question' + i.toString(),
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
    );
  }
  _consult.stringListQuestions = [];
  _consult.stringListQuestions = stringList;
  return returnList;
  //turn the snapshot to a list of widget as you like...
}
