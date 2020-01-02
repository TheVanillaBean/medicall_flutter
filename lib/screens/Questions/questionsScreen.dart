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
import 'package:oktoast/oktoast.dart';
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
  List<dynamic> combinedList = [];

  @override
  void initState() {
    super.initState();
    getConsult().then((onValue) {
      setState(() {
        _consult.consultType = onValue["consultType"];
        _consult.provider = onValue["provider"];
        _consult.price = onValue["price"];
        _consult.providerTitles = onValue["providerTitles"];
        _consult.screeningQuestions = onValue["screeningQuestions"];
        _consult.historyQuestions = onValue["historyQuestions"];
        _consult.uploadQuestions = onValue["uploadQuestions"];
        if (medicallUser.hasMedicalHistory) {
          combinedList = [
            ..._consult.screeningQuestions,
            ..._consult.uploadQuestions
          ];
        } else {
          widget.data['consult'].consultType = "Medical History";
          combinedList = [
            ..._consult.historyQuestions,
          ];
        }

        for (var i = 0; i < combinedList.length; i++) {
          globalKeyList['questionKey' + i.toString()] = GlobalKey();
        }
      });
    });
  }

  Future getConsult() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return jsonDecode(pref.getString('consult'));
  }

  setConsult(context) async {
    SharedPreferences _thisConsult = await SharedPreferences.getInstance();

    String currentConsultString = jsonEncode(_consult);
    await _thisConsult.setString("consult", currentConsultString);
  }

  Future<void> _onIntroEnd(context) async {
    //await setConsult(context);
    if (widget.data['consult'].consultType == 'Medical History') {
      medicallUser.hasMedicalHistory = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("Medical History Complete"),
            content: Text(
                "Thank you for filling out your account medical history, this is now saved to your account, it will only need to be updated if you have changes in your medical history."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                color: Theme.of(context).colorScheme.primary,
                child: Text("Continue to " + _consult.consultType == 'Lesion'
                    ? 'Spot'
                    : "Continue to " + _consult.consultType + ' treatment'),
                onPressed: () {
                  GlobalNavigatorKey.key.currentState.pop();
                  GlobalNavigatorKey.key.currentState.pushReplacementNamed(
                      '/questionsScreen',
                      arguments: {'user': medicallUser, 'consult': _consult});
                },
              ),
            ],
          );
        },
      );
    } else {
      widget.data['consult'].consultType = _consult.consultType;
      GlobalNavigatorKey.key.currentState.pushNamed('/selectProvider',
          arguments: {'user': medicallUser, 'consult': _consult});
    }
  }

  void _checkQuestion(index, context) {
    var tabController = context.state.questionsFormKey.currentContext.state;
    var listKeys = [];
    this.globalKeyList.forEach((k, v) => listKeys.add({'key': k, 'value': v}));
    var formAnswer = combinedList[int.parse(
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
                  0 ||
          this
              .combinedList[index != 0 ? index - 1 : index]
              .containsKey('not_required')) {
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
        showToast('Please fill out the required question.',
            position: ToastPosition(align: Alignment.center));
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
      contentPadding: EdgeInsets.zero,
      imagePadding: EdgeInsets.zero,
    );

    List<PageViewModel> pageViewList = [];

    for (var i = 0; i < combinedList.length; i++) {
      if (combinedList[i]['visible']) {
        pageViewList.add(PageViewModel(
            titleWidget: SizedBox(),
            bodyWidget: BuildQuestions(
              data: {
                'data': combinedList[i],
                'questionIndex': 'screening_questions',
                'dynamicAdd': null,
                'parent': context,
                'widget': widget,
                'questions': combinedList,
                'key': globalKeyList['questionKey' + i.toString()],
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
        title: Text(widget.data['consult'].consultType == 'Lesion'
            ? 'Spot'
            : widget.data['consult'].consultType),
      ),
      body: pageViewList.length > 0
          ? IntroductionScreen(
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
                spacing: EdgeInsets.all(1),
                color: Colors.grey,
                activeColor: Theme.of(context).colorScheme.primary,
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
