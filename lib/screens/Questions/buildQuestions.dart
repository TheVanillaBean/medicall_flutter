import 'package:Medicall/common_widgets/carousel/carousel_with_indicator.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class BuildQuestions extends StatefulWidget {
  final data;
  BuildQuestions({Key key, this.data}) : super(key: key);

  _BuildQuestionsState createState() => _BuildQuestionsState();
}

class _BuildQuestionsState extends State<BuildQuestions> {
  ValueChanged _onChangedDropDown;
  ValueChanged _onChangedInput;
  ValueChanged _onChangedCheckBox;
  List<Widget> _returnListWidget = [];
  List<dynamic> _options = [];
  ExtImageProvider _extImageProvider;
  Database _db;

  @override
  Widget build(BuildContext context) {
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    _db = Provider.of<Database>(context);
    _extImageProvider.currentAssetList = [];
    return buildQuestions(
        widget.data['data'],
        widget.data['questionIndex'],
        widget.data['dynamicAdd'],
        widget.data['parent'],
        widget.data['widget'],
        widget.data['key'],
        widget.data['questions']);
  }

  _buildGroupedQuestions(question, index, val, questions) {
    if (question.containsKey('image')) {
      if (questions['image'] != null && questions['image'].length > 0) {
        if (_extImageProvider.currentAssetList != questions['image'] &&
            _extImageProvider.currentAssetList.length > 0) {
          questions['image'] = _extImageProvider.currentAssetList;
        } else {
          _extImageProvider.currentAssetList = [];
          _extImageProvider.currentAssetList = questions['image'];
        }
      } else {
        questions['image'] = _extImageProvider.currentAssetList;
      }

      _returnListWidget.add(Visibility(
          visible: questions['visible'],
          child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      question['question'],
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: loadAssets,
                    child: FutureBuilder(
                        future: _extImageProvider
                            .convertImages(context), // a Future<String> or null
                        builder: (BuildContext context,
                            AsyncSnapshot<void> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            returnCarousel(question);
                          }

                          bool _areImagesConverted = false;
                          for (var i = 0; i < question['image'].length; i++) {
                            if (_extImageProvider.convertedImages
                                .containsKey(question['image'][i].name)) {
                              _areImagesConverted = true;
                            }
                          }
                          if (_areImagesConverted) {
                            return returnCarousel(question);
                          } else {
                            return returnPlaceHolder(question);
                          }
                        }),
                  ),
                ]),
          )));
    } else {
      if (index == null) {
        String type = questions['type'];
        if (questions['visible']) {
          _returnListWidget.add(SingleChildScrollView(
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
                      ? Theme(
                          data: ThemeData(
                              buttonTheme:
                                  ButtonThemeData(alignedDropdown: true)),
                          child: FormBuilderDropdown(
                            isExpanded: true,
                            attribute: 'question0',
                            initialValue: question['answer'] != null
                                ? questions['answer'].runtimeType == List &&
                                        questions['answer'].length > 0
                                    ? questions['answer'][1]
                                    : questions['answer'].runtimeType == String
                                        ? questions['answer']
                                        : questions['answer'][0]
                                : null,
                            decoration: InputDecoration(
                                fillColor: Color.fromRGBO(35, 179, 232, 0.2),
                                filled: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 10, 10),
                                border: InputBorder.none),
                            validators: [
                              FormBuilderValidators.required(),
                            ],
                            onChanged: _onChangedDropDown,
                            items: _options
                                .map((lang) => DropdownMenuItem(
                                    value: lang, child: Text(lang)))
                                .toList(),
                          ),
                        )
                      : type == 'checkbox'
                          ? FormBuilderCheckboxList(
                              leadingInput: true,
                              initialValue: questions['answer'] != null &&
                                      questions['answer'].length > 0
                                  ? questions['answer']
                                  : null,
                              attribute: 'question0',
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              validators: [
                                FormBuilderValidators.required(),
                              ],
                              onChanged: _onChangedCheckBox,
                              options: _options
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
                                    attribute: 'question0',
                                    initialValue: false,
                                  ),
                                )
                              : FormBuilderTextField(
                                  onChanged: _onChangedInput,
                                  initialValue: questions['answer'] != null &&
                                          questions['answer'].length > 0
                                      ? questions['parent_question'] ==
                                              'Diagnosis:'
                                          ? formatDiagnosisQuestion(questions)
                                          : questions['answer']
                                      : null,
                                  attribute: 'question0',
                                  minLines: 10,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
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
      }
    }
    return _returnListWidget;
  }

  formatDiagnosisQuestion(question) {
    String strNum = question['answer'];
    final newString =
        strNum.replaceAllMapped(RegExp(r'\[([^\[\]]*)\]'), (match) {
      var goup = match.group(0);
      if (goup == '[NAME]') {
        String name = _db.consultSnapshot.data['patient']
                .split(' ')[0][0]
                .toUpperCase() +
            _db.consultSnapshot.data['patient'].split(' ')[0].substring(1) +
            ' ' +
            _db.consultSnapshot.data['patient'].split(' ')[1][0].toUpperCase() +
            _db.consultSnapshot.data['patient'].split(' ')[1].substring(1) +
            ', \n\n';
        return name;
      }
      List conList;
      if (_db.consultSnapshot.data['type'] == 'Hairloss' &&
          goup.contains('*')) {
        String conditionStr;
        String oldStr =
            goup.replaceAllMapped(RegExp(r'\*([^\*\*\]]*)\*'), (match) {
          conditionStr = match.group(0);
          return match.group(0);
        });
        conList =
            conditionStr.replaceAll('[', '').replaceAll('*', '').split(',');
        for (var i = 0; i < widget.data['questions'].length; i++) {
          if (widget.data['questions'][i]['visible'] &&
              widget.data['questions'][i]['question'] == "Treatment:" &&
              widget.data['questions'][i]['answer'].length > 0) {
            String ans = widget.data['questions'][i]['answer'][0].toLowerCase();
            for (var x = 0; x < conList.length; x++) {
              if (ans.contains(conList[x].toLowerCase())) {
                int firstInx = oldStr.lastIndexOf('*');
                return '\n\n' +
                    oldStr.substring(firstInx + 2, oldStr.length - 1) +
                    '\n\n';
              }
            }
          }
        }
      }
      return '';
    });
    question['answer'] = newString;
    return newString;
  }

  buildQuestions(
      data, questionIndex, dynamicAdd, parent, widget, key, questions) {
    var questions = data;
    if (data != null) {
      _onChangedDropDown = (val) {
        Map fields = key.currentState.fields;
        fields.forEach((k, v) {
          if (fields[k].currentState.value == val) {
            data["answer"] = val;
          }
        });
      };
      _onChangedInput = (val) {
        data["answer"] = val;
      };
      _onChangedCheckBox = (val) {
        if (val.length >= 2 && val[1] == 'Yes' ||
            val.length >= 2 && data['question'] == 'Diagnosis:' ||
            val.length >= 2 && data['question'] == 'Exam:' ||
            val.length >= 2 && data['question'] == 'Treatment:') {
          val.removeAt(0);
        }
        if (val.length >= 2 && val[1] == 'No' ||
            val.length >= 2 && data['question'] == 'Diagnosis:' ||
            val.length >= 2 && data['question'] == 'Exam:' ||
            val.length >= 2 && data['question'] == 'Treatment:') {
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
              } else {
                for (var i = 0; i < this.widget.data['questions'].length; i++) {
                  if (this
                      .widget
                      .data['questions'][i]
                      .containsKey('parent_question')) {
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
                              currQuestionObj['index'] ==
                                  this.widget.data['questions'][i]
                                      ['parent_index'] &&
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
            }
          });
        });
      };
      _returnListWidget = [];
      if (questions is Map) {
        _options = questions['options'];
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
          _options = questions[x]['options'];
          _buildGroupedQuestions(questions[x], x, null, questions);
        }
      }

      //turn the snapshot to a list of widget as you like...
    }
    return FormBuilder(
        key: key,
        child: Column(
          children: _returnListWidget,
        ));
  }

  Widget buildGridView() {
    List<Widget> _returnListWidget = [];
    if (widget.data['data']['image'].length > 0) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.62,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: CarouselWithIndicator(
                  imgList: widget.data['data']['image'],
                  from: 'buildQuestions'),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, 37.0, 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60.0),
                child: Container(
                  padding: EdgeInsets.all(15),
                  color: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    _returnListWidget.add(Container(
      transform: Matrix4.translationValues(0.0, -37.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60.0),
        child: Container(
          padding: EdgeInsets.all(15),
          color: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    ));

    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
      child: Column(
        children: _returnListWidget,
      ),
    );
  }

  Future<void> loadAssets() async {
    String error = '';
    try {
      await _extImageProvider
          .pickImages(
              _extImageProvider.currentAssetList,
              widget.data['data']['max_images'],
              true,
              _extImageProvider.pickImagesCupertinoOptions(
                  takePhotoIcon: 'chat'),
              _extImageProvider.pickImagesMaterialOptions(
                  lightStatusBar: false,
                  autoCloseOnSelectionLimit: true,
                  startInAllView: true,
                  actionBarTitle: 'Select Images',
                  allViewTitle: 'All Photos'),
              context)
          .then((onValue) {
        _extImageProvider.currentAssetList = onValue;
        for (var i = 0; i < onValue.length; i++) {
          _extImageProvider.assetList.add(onValue[i]);
        }
        widget.data['data']['image'] = onValue;
        setState(() {});
      });
    } on Exception catch (e) {
      if (e.toString() != 'The user has cancelled the selection') {
        error = e.toString();
      }
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    print(error);
  }

  returnCarousel(question) {
    return question['image'].length > 0
        ? buildGridView()
        : returnPlaceHolder(question);
  }

  returnPlaceHolder(question) {
    return question['media'].length > 0
        ? Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                _extImageProvider.returnNetworkImage(
                  question['media'],
                  height: 440,
                  cache: true,
                  fit: BoxFit.fill,
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, 37.0, 0.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60.0),
                    child: Container(
                      padding: EdgeInsets.all(15),
                      color: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey.withAlpha(200),
                            size: 50,
                          ),
                          height: MediaQuery.of(context).size.height * 0.31,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(100),
                            border: Border(
                              left: BorderSide(
                                //                   <--- left side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.withAlpha(200),
                          ),
                          height: MediaQuery.of(context).size.height * 0.31,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(100),
                            border: Border(
                              right: BorderSide(
                                //                   <--- left side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              left: BorderSide(
                                //                   <--- left side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.withAlpha(200),
                          ),
                          height: MediaQuery.of(context).size.height * 0.31,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(100),
                            border: Border(
                              left: BorderSide(
                                //                   <--- left side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                //                    <--- top side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey.withAlpha(200),
                          ),
                          height: MediaQuery.of(context).size.height * 0.31,
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(100),
                            border: Border(
                              right: BorderSide(
                                //                   <--- left side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              left: BorderSide(
                                //                   <--- left side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                //                    <--- top side
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Container(
                transform: Matrix4.translationValues(0.0, 37.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60.0),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    color: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
