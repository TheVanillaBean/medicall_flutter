import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

buildQuestions(data, questionIndex, dynamicAdd, widget, key) {
  List<Widget> returnList = [];
  ValueChanged _onChanged;
  var questions = data;
  var stringList = [];

  for (var i = 0; i < questions.length; i++) {
    String question = questions[i]['question'];
    if (questionIndex == 'medical_history_questions' &&
        i == 0 &&
        dynamicAdd != null) {
      question = question + dynamicAdd;
    }
    stringList.add(question);
    List<dynamic> options = questions[i]['options'];

    if (options != null) {
      if (options[1] == 'Yes') {
        _onChanged = (val) {
          if (val.length > 2 && val[1] == 'Yes') {
            val.removeAt(1);
          }
          if (val.length > 2 && val[1] == 'No') {
            val.removeAt(1);
          }
          Map fields = key.currentState.fields;
          fields.forEach((k, v) {
            if (fields[k].currentState.value == val) {
              if (val[0] == "") {
                val[0] = null;
              }
              data[int.parse(k.substring(k.length - 1))]["answer"] = val;
              print(val);
            }
          });
        };
      }
    } else {
      options = [""];
      _onChanged = (val) {
        Map fields = key.currentState.fields;
        fields.forEach((k, v) {
          if (fields[k].currentState.value == val) {
            data[int.parse(k.substring(k.length - 1))]["answer"] = val;
          }
        });
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
                    initialValue: data[i]['answer'] != null
                        ? data[i]['answer'].runtimeType == List &&
                                data[i]['answer'].length > 0
                            ? data[i]['answer'][1]
                            : data[i]['answer'].runtimeType == String
                                ? data[i]['answer']
                                : data[i]['answer'][0]
                        : options[0],
                    attribute: 'question' + i.toString(),
                    decoration: InputDecoration(
                        fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                        filled: true,
                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: InputBorder.none),
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                    onChanged: _onChanged,
                    items: options
                        .map((lang) =>
                            DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    readonly: false,
                  ),
                )
              : type == 'checkbox'
                  ? FormBuilderCheckboxList(
                      leadingInput: true,
                      initialValue: data[i]['answer'],
                      attribute: 'question' + i.toString(),
                      validators: [
                        FormBuilderValidators.required(),
                      ],
                      onChanged: _onChanged,
                      options: options
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
                          onChanged: _onChanged,
                          initialValue: data[i]['answer'],
                          attribute: 'question' + i.toString(),
                          validators: [
                            //FormBuilderValidators.required(),
                          ],
                        ),
        ],
      ),
    );
  }

  return FormBuilder(
      key: key,
      child: Column(
        children: returnList,
      ));
  //turn the snapshot to a list of widget as you like...
}
