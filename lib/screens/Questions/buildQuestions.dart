import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class BuildQuestions extends StatefulWidget {
  final data;
  BuildQuestions({Key key, this.data}) : super(key: key);

  _BuildQuestionsState createState() => _BuildQuestionsState();
}

class _BuildQuestionsState extends State<BuildQuestions> {
  buildQuestions(data, questionIndex, dynamicAdd, widget, key) {
    List<Widget> returnList = [];
    if (data != null) {
      ValueChanged _onChangedDropDown;
      ValueChanged _onChangedInput;
      ValueChanged _onChangedCheckBox;
      var questions = data;
      List<dynamic> options = [];

      _buildGroupedQuestions(question, index, val) {
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
                                : data[index]['answer'].runtimeType == String
                                    ? data[index]['answer']
                                    : data[index]['answer'][0]
                            : options[0],
                        attribute: 'question_' + index.toString(),
                        decoration: InputDecoration(
                            fillColor: Color.fromRGBO(35, 179, 232, 0.1),
                            filled: true,
                            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                              .map(
                                  (lang) => FormBuilderFieldOption(value: lang))
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
            data[int.parse(k.substring(k.length - 1))]["answer"] = val;
          }
        });
      };
      _onChangedCheckBox = (val) {
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
              Map currQuestionObj = data[int.parse(k.split('_')[1])];
              currQuestionObj["answer"] = val;
              for (var i = 0; i < data.length; i++) {
                if (currQuestionObj["question"] == data[i]['parent_question']) {
                  var currentOption = currQuestionObj['answer']
                      .contains(currQuestionObj["options"][data[i]['index']]);
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
            }
          });
        });
      };

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
        _buildGroupedQuestions(questions[x], x, null);
      }

      //turn the snapshot to a list of widget as you like...
    }
    return FormBuilder(
        key: key,
        child: Column(
          children: returnList,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildQuestions(widget.data['data'], widget.data['questionIndex'],
        widget.data['dynamicAdd'], widget.data['widget'], widget.data['key']);
  }
}
