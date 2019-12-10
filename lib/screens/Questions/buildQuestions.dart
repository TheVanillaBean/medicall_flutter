import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class BuildQuestions extends StatefulWidget {
  final data;
  BuildQuestions({Key key, this.data}) : super(key: key);

  _BuildQuestionsState createState() => _BuildQuestionsState();
}

class _BuildQuestionsState extends State<BuildQuestions> {
  @override
  Widget build(BuildContext context) {
    buildQuestions(
        data, questionIndex, dynamicAdd, parent, widget, key, questions) {
      List<Widget> returnList = [];
      if (data != null) {
        ValueChanged _onChangedDropDown;
        ValueChanged _onChangedInput;
        ValueChanged _onChangedCheckBox;
        var questions = data;
        List<dynamic> options = [];

        _buildGroupedQuestions(question, index, val, questions) {
          if (index == null) {
            String type = questions['type'];
            if (questions['visible']) {
              returnList.add(SingleChildScrollView(
                child: Visibility(
                  visible: questions['visible'],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            question['question'],
                          ),
                        ),
                      ),
                      type == 'dropdown'
                          ? DropdownButtonHideUnderline(
                              child: FormBuilderDropdown(
                                initialValue: data['answer'] != null
                                    ? data['answer'].runtimeType == List &&
                                            data['answer'].length > 0
                                        ? data['answer'][1]
                                        : data['answer'].runtimeType == String
                                            ? data['answer']
                                            : data['answer'][0]
                                    : options[0],
                                attribute: 'question0',
                                decoration: InputDecoration(
                                    fillColor:
                                        Color.fromRGBO(35, 179, 232, 0.1),
                                    filled: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    border: InputBorder.none),
                                validators: [
                                  FormBuilderValidators.required(),
                                ],
                                onChanged: _onChangedDropDown,
                                items: options
                                    .map((lang) => DropdownMenuItem(
                                        value: lang, child: Text(lang)))
                                    .toList(),
                              ),
                            )
                          : type == 'checkbox'
                              ? FormBuilderCheckboxList(
                                  leadingInput: true,
                                  initialValue: data['answer'],
                                  attribute: 'question0',
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                  validators: [
                                    FormBuilderValidators.required(),
                                  ],
                                  onChanged: _onChangedCheckBox,
                                  options: options
                                      .map((lang) =>
                                          FormBuilderFieldOption(value: lang))
                                      .toList(),
                                )
                              : type == 'switch'
                                  ? DropdownButtonHideUnderline(
                                      child: FormBuilderSwitch(
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            border: InputBorder.none),
                                        label: Text(''),
                                        attribute: 'question0',
                                        initialValue: false,
                                      ),
                                    )
                                  : FormBuilderTextField(
                                      onChanged: _onChangedInput,
                                      initialValue: null,
                                      attribute: 'question0',
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                      ),
                                      validators: [
                                        //FormBuilderValidators.required(),
                                      ],
                                    ),
                    ],
                  ),
                ),
              ));
            }
          } else {
            String type = questions[index]['type'];
            returnList.add(Visibility(
              visible: questions[index]['visible'],
              child: Column(
                children: <Widget>[
                  index != 0
                      ? SizedBox(
                          height: 20,
                        )
                      : SizedBox(height: 0),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        question['question'],
                      ),
                    ),
                  ),
                  type == 'dropdown'
                      ? DropdownButtonHideUnderline(
                          child: FormBuilderDropdown(
                            initialValue: data[index]['answer'] != null
                                ? data[index]['answer'].runtimeType == List &&
                                        data[index]['answer'].length > 0
                                    ? data[index]['answer'][1]
                                    : data[index]['answer'].runtimeType ==
                                            String
                                        ? data[index]['answer']
                                        : data[index]['answer'][0]
                                : options[0],
                            attribute: 'question_' + index.toString(),
                            decoration: InputDecoration(
                                fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                                filled: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                            onChanged: _onChangedDropDown,
                            items: options
                                .map((lang) => DropdownMenuItem(
                                    value: lang, child: Text(lang)))
                                .toList(),
                          ),
                        )
                      : type == 'checkbox'
                          ? FormBuilderCheckboxList(
                              leadingInput: true,
                              initialValue: data[index]['answer'],
                              attribute: 'question_' + index.toString(),
                              validators: [
                                FormBuilderValidators.required(),
                              ],
                              onChanged: _onChangedCheckBox,
                              options: options
                                  .map((lang) =>
                                      FormBuilderFieldOption(value: lang))
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
                                    attribute: 'question_' + index.toString(),
                                    initialValue: false,
                                  ),
                                )
                              : FormBuilderTextField(
                                  onChanged: _onChangedInput,
                                  initialValue: null,
                                  attribute: 'question_' + index.toString(),
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.0),
                                    ),
                                  ),
                                  validators: [
                                    //FormBuilderValidators.required(),
                                  ],
                                ),
                ],
              ),
            ));
          }

          return returnList;
        }

        _onChangedDropDown = (val) {
          Map fields = key.currentState.fields;
          fields.forEach((k, v) {
            if (fields[k].currentState.value == val) {
              data[int.parse(k.substring(k.length - 1))]["answer"] = val;
            }
          });
        };
        _onChangedInput = (val) {
          Map fields = key.currentState.fields;
          fields.forEach((k, v) {
            if (fields[k].currentState.value == val) {
              data["answer"] = val;
            }
          });
        };
        _onChangedCheckBox = (val) {
          var indiciesToBeToggled = [];
          if (val.length >= 2 && val[1] == 'Yes') {
            val.removeAt(0);
          }
          if (val.length >= 2 && val[1] == 'No') {
            val.removeAt(0);
          }
          setState(() {
            Map fields = key.currentState.fields;
            fields.forEach((k, v) {
              if (fields[k].currentState.value == val) {
                Map currQuestionObj = data;
                currQuestionObj["answer"] = val;

                key.currentState.value[k] = fields[k].currentState.value;

                if (!data.containsKey('answer')) {
                  for (var i = 0; i < data.length; i++) {
                    if (currQuestionObj["question"] ==
                        data[i]['parent_question']) {
                      var currentOption = currQuestionObj['answer'].contains(
                          currQuestionObj["options"][data[i]['index']]);
                      if (currentOption) {
                        setState(() {
                          data[i]['visible'] = true;
                        });
                      } else {
                        setState(() {
                          data[i]['visible'] = false;
                        });
                      }
                    }
                  }
                } else {
                  for (var i = 0;
                      i < this.widget.data['questions'].length;
                      i++) {
                    if (currQuestionObj["question"] ==
                        this.widget.data['questions'][i]['parent_question']) {
                      if (currQuestionObj["answer"].length > 0) {
                        for (var x = 0;
                            x < currQuestionObj["answer"].length;
                            x++) {
                          var currIndex = currQuestionObj["options"]
                              .indexOf(currQuestionObj["answer"][x]);

                          var widgetIndex =
                              this.widget.data['questions'][i]['index'];
                          if (currIndex == widgetIndex &&
                              !this.widget.data['questions'][i]["visible"] &&
                              currQuestionObj["answer"].indexOf(
                                      currQuestionObj["options"][this
                                          .widget
                                          .data['questions'][i]["index"]]) !=
                                  -1) {
                            this.widget.data['parent'].state.setState(() {
                              this.widget.data['questions'][i]['visible'] =
                                  true;
                            });
                          }
                          if (currQuestionObj["answer"].indexOf(
                                  currQuestionObj["options"][this
                                      .widget
                                      .data['questions'][i]["index"]]) ==
                              -1) {
                            this.widget.data['parent'].state.setState(() {
                              this.widget.data['questions'][i]['visible'] =
                                  false;
                            });
                          }
                        }
                      } else {
                        for (var i = 0;
                            i < this.widget.data['questions'].length;
                            i++) {
                          if (currQuestionObj["question"] ==
                              this.widget.data['questions'][i]
                                  ['parent_question']) {
                            this.widget.data['parent'].state.setState(() {
                              this.widget.data['questions'][i]['visible'] =
                                  false;
                            });
                          }
                        }
                      }
                    }
                  }
                }
              }
            });
          });
        };
        if (questions is Map) {
          options = questions['options'];
          _buildGroupedQuestions(questions, null, null, questions);
        } else {
          for (var x = 0; x < questions.length; x++) {
            String question = questions[x]['question'];
            if (questionIndex == 'medical_history_questions' &&
                x == 0 &&
                dynamicAdd != null) {
              if (!questions[x]['question'].contains(dynamicAdd)) {
                questions[x]['question'] = question + ' ' + dynamicAdd;
              }
            }
            options = questions[x]['options'];
            _buildGroupedQuestions(questions[x], x, null, questions);
          }
        }

        //turn the snapshot to a list of widget as you like...
      }
      return FormBuilder(
          key: key,
          child: Column(
            children: returnList,
          ));
    }

    return buildQuestions(
        widget.data['data'],
        widget.data['questionIndex'],
        widget.data['dynamicAdd'],
        widget.data['parent'],
        widget.data['widget'],
        widget.data['key'],
        widget.data['questions']);
  }
}
