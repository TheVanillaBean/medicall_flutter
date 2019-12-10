import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/util/introduction_screen/introduction_screen.dart';
import 'package:Medicall/util/introduction_screen/model/page_decoration.dart';
import 'package:Medicall/util/introduction_screen/model/page_view_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buildQuestions.dart';

class QuestionsScreen extends StatefulWidget {
  final data;
  QuestionsScreen({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  Map globalKeyList = {};
  GlobalKey<FormBuilderState> questionsFormKey = GlobalKey();
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  var screeningQuestions;
  var ranOnce = false;
  var medicalHistoryQuestions;
  bool showSegmentedControl = true;
  ConsultData _consult = ConsultData();

  @override
  void initState() {
    super.initState();
    getConsult().then((onValue) {
      setState(() {
        _consult.consultType = onValue["consultType"];
        _consult.provider = onValue["provider"];
        _consult.providerTitles = onValue["providerTitles"];
        _consult.screeningQuestions = onValue["screeningQuestions"];
        _consult.historyQuestions = onValue["historyQuestions"];
        _consult.uploadQuestions = onValue["uploadQuestions"];
      });
    });
    for (var i = 0; i < widget.data.screeningQuestions.length; i++) {
      globalKeyList['questionKey' + i.toString()] = GlobalKey();
    }
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return jsonDecode(pref.getString('consult'));
  }

  setConsult() async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();
    int index = 0;
    questionsFormKey.currentState.value.forEach((k, v) {
      _consult.screeningQuestions[index]["answer"] =
          questionsFormKey.currentState.value[k];
      index++;
    });
    String currentConsultString = jsonEncode(_consult);
    await _thisConsult.setString("consult", currentConsultString);
  }

  void _onIntroEnd(context) {
    GlobalNavigatorKey.key.currentState
        .pushNamed('/questionsScreening', arguments: {'user': medicallUser});
  }

  void _checkQuestion(index, context) {
    // for (var i = 0; i < widget.data.screeningQuestions.length; i++) {
    //   if (widget.data.screeningQuestions[i]['parent_question'] ==
    //       widget.data.screeningQuestions[index]['question']) {
    //     globalKeyList['questionKey' + i.toString()] = GlobalKey();
    //   }
    // }
    var tabController = context.state.questionsFormKey.currentContext.state;
    var listKeys = [];
    this.globalKeyList.forEach((k, v) => listKeys.add({'key': k, 'value': v}));
    var formAnswer = widget.data.screeningQuestions[int.parse(
            listKeys[index != 0 ? index - 1 : index]['key'].split('Key')[1])]
        ['answer'];
    var currentState =
        listKeys[index != 0 ? index - 1 : index]['value'].currentState;
    if (formAnswer != null &&
        currentState != null &&
        currentState.value['question0'] != formAnswer) {
      currentState.value['question0'] = formAnswer;
    }

    if (this
            .globalKeyList[listKeys[index != 0 ? index - 1 : index]['key']]
            .currentState !=
        null) {
      if (this
                  .globalKeyList[listKeys[index != 0 ? index - 1 : index]
                      ['key']]
                  .currentState
                  .value
                  .length >
              0 &&
          this
                  .globalKeyList[listKeys[index != 0 ? index - 1 : index]
                      ['key']]
                  .currentState
                  .value['question0']
                  .length >
              0) {
        tabController.pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      } else {
        tabController.pageController.animateToPage(
          index != 0 ? index - 1 : index,
          duration: Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    List<PageViewModel> pageViewList = [];

    for (var i = 0; i < widget.data.screeningQuestions.length; i++) {
      if (widget.data.screeningQuestions[i]['visible']) {
        pageViewList.add(PageViewModel(
            titleWidget: SizedBox(),
            bodyWidget: BuildQuestions(
              data: {
                'data': widget.data.screeningQuestions[i],
                'questionIndex': 'screening_questions',
                'dynamicAdd': null,
                'parent': context,
                'widget': widget,
                'questions': widget.data.screeningQuestions,
                'key': globalKeyList['questionKey' + i.toString()]
              },
            ),
            decoration: pageDecoration));
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(widget.data.consultType),
      ),
      body: IntroductionScreen(
        pages: pageViewList,
        key: questionsFormKey,
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: false,
        skipFlex: 0,
        nextFlex: 0,
        onChange: (i) => _checkQuestion(i, context),
        skip: Text(
          'Skip',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        next: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.secondary,
        ),
        done: Text(
          'Done',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        dotsFlex: 1,
        dotsDecorator: DotsDecorator(
          size: Size(10.0, 10.0),
          spacing: EdgeInsets.all(5),
          color: Colors.grey,
          activeColor: Theme.of(context).colorScheme.primary,
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
